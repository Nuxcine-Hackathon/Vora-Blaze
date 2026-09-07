class InitialRideRequest {
  final String rideId;
  final String pickupLocation;
  final String dropoffLocation;
  final String userId;
  final Customer customer;
  final ParcalData parcalData;
  final String travelCharges;
  final String status;
  final String travelDistance;
  final String travelTime;
  final String playerId;

  InitialRideRequest({
    required this.rideId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.userId,
    required this.customer,
    required this.parcalData,
    required this.travelCharges,
    required this.status,
    required this.travelDistance,
    required this.travelTime,
    required this.playerId ,
  });

  factory InitialRideRequest.fromJson(Map<String, dynamic> json) {
    return InitialRideRequest(
      rideId: json['rideId'] as String? ?? '',
      pickupLocation: json['pickupLocation'] as String? ?? '',
      dropoffLocation: json['dropoffLocation'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      customer:Customer.fromJson(json['customer'] as Map<String, dynamic>? ?? {}),
      parcalData:ParcalData.fromJson(json['parcelData'] as Map<String, dynamic>? ?? {}),
      travelCharges: json['travelCharges'] as String? ?? '',
      status: json['status'] as String? ?? '',
      travelDistance: json['travelDistance'] as String? ?? '',
      travelTime: json['travelTime'] as String? ?? '',
      playerId: json['playerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'userId': userId,
      'customer': customer.toJson(),
      'travelCharges': travelCharges,
      'status': status,
      'travelDistance': travelDistance,
      'travelTime': travelTime,
      'playerId': playerId,
    };
  }
}

class Customer {
  final String userName;
  final String userPhone;
  final String? userPhoto;
  final String userRating;

  Customer({
    required this.userName,
    required this.userPhone,
    this.userPhoto,
    required this.userRating,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      userPhoto: json['userPhoto'] as String?,
      userRating: json['userRating'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userPhone': userPhone,
      'userPhoto': userPhoto,
      'userRating': userRating,
    };
  }
}

class ParcalData {
  final String? name;
  final String? weight;
  final String? reciverName;
  final String? reciverNumber;
  final String? instruction;

  ParcalData({
    this.name,
      this.weight,
    this.reciverName,
     this.reciverNumber,
     this.instruction,
  });

  factory ParcalData.fromJson(Map<String, dynamic> json) {
    return ParcalData(
      name: json['name'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      reciverName: json['receiverName'] as String?,
      reciverNumber: json['receiverPhone'] as String?,
      instruction: json['pickupInstructions'] as String? ?? '',
    );
  }

  
  
}
