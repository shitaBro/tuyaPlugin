class TuyaDevModel {
  String? uuid;
  int? homeId;
  String? productId;
  String? mac;
  bool? isActive;
  int? bleType; //TYSmartBLETypeUnknow = 1,

  String? address;
  // TYSmartBLETypeBLE,
  //
  // TYSmartBLETypeBLEPlus,
  //
  // TYSmartBLETypeBLEWifi,
  //
  // TYSmartBLETypeBLESecurity,
  //
  // TYSmartBLETypeBLEWifiSecurity,
  //
  // TYSmartBLETypeBLEWifiPlugPlay,
  //
  // TYSmartBLETypeBLEZigbee,
  //
  // TYSmartBLETypeBLELTESecurity,
  //
  // TYSmartBLETypeBLEBeacon,
  //
  // TYSmartBLETypeBLEWifiPriorBLE,
  bool? isSupport5G;
  bool? isProuductKey;
  int? bleProtocolV;
  bool? isQRCodeDevice;
  bool? isSupportMultiUserShare;

  TuyaDevModel(
      {this.uuid,
      this.productId,
      this.mac,
      this.isActive,
      this.bleType,
      this.isSupport5G,
      this.isProuductKey,
      this.bleProtocolV,
      this.isQRCodeDevice,
      this.isSupportMultiUserShare,
      this.address});
  TuyaDevModel.fromJson(Map<String, dynamic> json) {
    uuid = json["uuid"].toString();
    productId = json["productId"].toString();
    mac = json["mac"].toString();
    isActive = json["isActive"].toString() == "1";
    bleType = json["bleType"];
    isSupport5G = json["isSupport5G"].toString() == "1";
    isProuductKey = json["isProuductKey"].toString() == "1";
    bleProtocolV = json["bleProtocolV"];
    isQRCodeDevice = json["isQRCodeDevice"].toString() == "1";
    isSupportMultiUserShare =
        json["isSupportMultiUserShare"].toString() == "1";
    homeId = json["homeId"];
    address = json["address"].toString();
  }
  Map<String,dynamic> toJson() {
    final Map<String,dynamic> data = new Map<String,dynamic>();
    data["uuid"] = uuid;
    data["productId"] = productId;
    data["mac"] = mac;
    data["isActive"] = isActive;
    data["bleType"] = bleType;
    data["isSupport5G"] = isSupport5G;
    data["isProuductKey"] = isProuductKey;
    data["bleProtocolV"] = bleProtocolV;
    data["isQRCodeDevice"] = isQRCodeDevice;
    data["isSupportMultiUserShare"] = isSupportMultiUserShare;
    data["homeId"] = homeId;
    data["address"] = address;
    return data;
  }
}
