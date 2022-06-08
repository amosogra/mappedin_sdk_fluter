    package com.example.mappedin_sdk_fluter

    import android.content.Context
    import android.view.View
    import android.view.LayoutInflater

    import androidx.annotation.NonNull

    import com.mappedin.sdk.MPIMapView
    import com.mappedin.sdk.listeners.MPIMapViewListener
    import com.mappedin.sdk.models.*
    import com.mappedin.sdk.web.MPIOptions

    import io.flutter.plugin.common.BinaryMessenger
    import io.flutter.plugin.common.MethodCall
    import io.flutter.plugin.common.MethodChannel
    import io.flutter.plugin.common.MethodChannel.Result
    import io.flutter.plugin.common.MethodChannel.MethodCallHandler
    import io.flutter.plugin.platform.PlatformView

    import java.io.BufferedReader


    class MapdinNativeWidget internal constructor(context: Context?, messenger: BinaryMessenger?, id: Int)
        : PlatformView, MethodCallHandler {

        private var view: View = LayoutInflater.from(context).inflate(R.layout.mpi_widget, null)
        private val venueDataString: String = readAsset(context!!, "mappedin-demo-mall.json")
        private val methodChannel: MethodChannel
        private lateinit var mapView: MPIMapView

        init {
            mapView = view.findViewById<MPIMapView>(R.id.mapView)
            methodChannel = MethodChannel(messenger, "plugins.amos.views/mappedin_$id")
            methodChannel.setMethodCallHandler(this)
            loadMap()
        }

        override fun getView(): View {
            return view
        }

        override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
            if (call.method == "getPlatformVersion") {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            else if(call.method == "updatePosition"){
                println("Update position call is triggered")
                val lat = call.argument<Double>("lat")
                val long = call.argument<Double>("long")
                val accuracy = call.argument<Double>("accuracy") ?: 7.170562529369844
                val floorLevel = call.argument<Int>("floor") ?: 0
                val updated = updatePosition(lat!!, long!!, accuracy, floorLevel)
                result.success(updated)
            }
            else {
                result.notImplemented()
            }
        }

        private fun loadMap() {
            mapView.listener = object: MPIMapViewListener {
                override fun onBlueDotPositionUpdate(update: MPIBlueDotPositionUpdate) {
                    // Called when the blueDot that tracks the user position is updated
                    println("Blue dot position updated")
                }

                override fun onBlueDotStateChange(stateChange: MPIBlueDotStateChange) {
                    // Called when the state of blueDot is changed
                    println("Blue dot state changed: " + stateChange.name.toString())
                }

                override fun onMapChanged(map: MPIMap) {
                    // Called when the map is changed
                    println("Map changed ${map.name}")
                }

                override fun onNothingClicked() {
                    // Called when a tap doesn't hit any spaces
                    println("Nothing clicked")
                }

                override fun onPolygonClicked(polygon: MPINavigatable.MPIPolygon) {
                    // Called when the polygon is clicked
                    println("Polygon clicked" + (polygon.name ?: polygon.id))
                }

                override fun onDataLoaded(data: MPIData) {
                    // Called when the mapView has finished loading both the view and venue data
                    println("Onloaded data")
                    mapView.blueDotManager.enable(MPIOptions.BlueDot(smoothing = false, showBearing = true))
                    mapView.blueDotManager.updatePosition(MPIPosition(coords = MPIPosition.MPICoordinates(latitude = 43.52023014, longitude = -80.5352595, accuracy = 7.170562529369844, floorLevel = 0)))
                    mapView.blueDotManager.setState(MPIState.FOLLOW)
                }

                override fun onFirstMapLoaded() {
                    // Called when the first map is fully loaded
                    println("First map loaded")
                }

                override fun onStateChanged(state: MPIState) {
                    println("State changed: $state")
                }
            }

            mapView.showVenue(venueDataString) {
                
            }
        }

        private fun updatePosition(latitude: Double, longitude: Double, accuracy: Double, floorLevel: Int): Boolean {
            println("Accuracy & floor: $accuracy, $floorLevel")
            mapView.blueDotManager.updatePosition(
                MPIPosition(coords = MPIPosition.MPICoordinates(
                    latitude = latitude,
                    longitude = longitude,
                    accuracy = accuracy,
                    floorLevel = floorLevel)
                )
            )
            println("Position updated")
            return true;
        }

        override fun dispose() {
            //methodChannel.setMethodCallHandler(null)
        }

        fun readAsset(context: Context, fileName: String): String =
    context
        .assets
        .open(fileName)
        .bufferedReader()
        .use(BufferedReader::readText)
}