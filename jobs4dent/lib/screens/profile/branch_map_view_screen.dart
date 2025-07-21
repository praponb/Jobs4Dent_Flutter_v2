import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/branch_model.dart';

class BranchMapViewScreen extends StatefulWidget {
  final BranchModel branch;

  const BranchMapViewScreen({
    super.key,
    required this.branch,
  });

  @override
  State<BranchMapViewScreen> createState() => _BranchMapViewScreenState();
}

class _BranchMapViewScreenState extends State<BranchMapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMarker();
  }

  void _setupMarker() {
    if (widget.branch.coordinates != null) {
      final marker = Marker(
        markerId: MarkerId(widget.branch.branchId),
        position: LatLng(
          widget.branch.coordinates!.latitude,
          widget.branch.coordinates!.longitude,
        ),
        infoWindow: InfoWindow(
          title: widget.branch.branchName,
          snippet: widget.branch.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      
      setState(() {
        _markers = {marker};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.branch.coordinates == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.branch.branchName),
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'ไม่มีข้อมูลตำแหน่งของสาขานี้',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final branchLocation = LatLng(
      widget.branch.coordinates!.latitude,
      widget.branch.coordinates!.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.branch.branchName),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showBranchInfo,
            icon: const Icon(Icons.info_outline),
            tooltip: 'ข้อมูลสาขา',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: branchLocation,
              zoom: 15.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
          ),
          // Branch info card at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildBranchInfoCard(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnBranch,
        backgroundColor: const Color(0xFF2196F3),
        tooltip: 'กลับไปที่ตำแหน่งสาขา',
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildBranchInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.branch.branchName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.branch.address.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.branch.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (widget.branch.contactNumber.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.branch.contactNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _centerOnBranch() {
    if (_mapController != null && widget.branch.coordinates != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.branch.coordinates!.latitude,
              widget.branch.coordinates!.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  void _showBranchInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Branch name
                Text(
                  widget.branch.branchName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Address
                if (widget.branch.address.isNotEmpty) ...[
                  _buildInfoRow(Icons.location_on, 'ที่อยู่', widget.branch.address),
                  const SizedBox(height: 12),
                ],
                
                // Contact
                if (widget.branch.contactNumber.isNotEmpty) ...[
                  _buildInfoRow(Icons.phone, 'เบอร์โทรศัพท์', widget.branch.contactNumber),
                  const SizedBox(height: 12),
                ],
                
                // Operating hours
                if (widget.branch.operatingHours.isNotEmpty) ...[
                  _buildOperatingHours(),
                  const SizedBox(height: 12),
                ],
                
                // Parking info
                if (widget.branch.parkingInfo.isNotEmpty) ...[
                  _buildInfoRow(Icons.local_parking, 'ที่จอดรถ', widget.branch.parkingInfo),
                  const SizedBox(height: 12),
                ],
                
                // Photos
                if (widget.branch.branchPhotos.isNotEmpty) ...[
                  const Text(
                    'รูปภาพสาขา',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.branch.branchPhotos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(widget.branch.branchPhotos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperatingHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              'เวลาทำการ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.branch.operatingHours.entries.map((entry) {
          final dayName = _getDayName(entry.key);
          return Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getDayName(String day) {
    const dayNames = {
      'monday': 'จันทร์',
      'tuesday': 'อังคาร',
      'wednesday': 'พุธ',
      'thursday': 'พฤหัสบดี',
      'friday': 'ศุกร์',
      'saturday': 'เสาร์',
      'sunday': 'อาทิตย์',
    };
    return dayNames[day.toLowerCase()] ?? day;
  }
} 