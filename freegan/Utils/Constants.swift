//
//  Constants.swift
//  freegan
//
//  Created by Hammed opejin on 1/9/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


var firebase = Database.database().reference()
let userDefaults = UserDefaults.standard


let SHADOW_GRAY: CGFloat = 120.0 / 255.0

let KEY_UID = "uid"


//User
public let kOBJECTID = "objectId"
public let kUSER = "users"
public let kCREATEDAT = "createdAt"
public let kUPDATEDAT = "updatedAt"
public let kEMAIL = "email"
public let kFACEBOOK = "facebook"
public let kLOGINMETHOD = "loginMethod"
public let kPUSHID = "pushId"
public let kFIRSTNAME = "firstname"
public let kLASTNAME = "lastname"
public let kFULLNAME = "fullname"
public let kUSERNAME = "userName"
public let kAVATAR = "userImgUrl"
public let kCURRENTUSER = "currentUser"

//typeing
public let kTYPINGPATH = "Typing"

//
public let kAVATARSTATE = "avatarState"
public let kFILEREFERENCE = "gs://freegan-42b40.appspot.com/"
public let kFIRSTRUN = "firstRun"
public let kNUMBEROFMESSAGES = 40
public let kMAXDURATION = 5.0
public let kAUDIOMAXDURATION = 10.0
public let kSUCCESS = 2

//recent
public let kRECENT = "Recent"
public let kCHATROOMID = "chatRoomID"
public let kUSERID = "userId"
public let kDATE = "date"
public let kPRIVATE = "private"
public let kGROUP = "group"
public let kGROUPID = "groupId"
public let kRECENTID = "recentId"
public let kMEMBERS = "members"
public let kDISCRIPTION = "discription"
public let kLASTMESSAGE = "lastMessage"
public let kCOUNTER = "counter"
public let kTYPE = "type"
public let kWITHUSERUSERNAME = "withUserUserName"
public let kWITHUSERUSERID = "withUserUserID"
public let kOWNERID = "ownerID"
public let kSTATUS = "status"
public let kMESSAGE = "Message"
public let kMESSAGES = "message"
public let kMESSAGEID = "messageId"
public let kNAME = "name"
public let kPOSTID = "postId"
public let kRECEIVERID = "receiverId"
public let kSENDERID = "senderId"
public let kSENDERNAME = "senderName"
public let kTHUMBNAIL = "thumbnail"

//blockedUsers
public let kBLOCKEDUSERS = "blockedUsers"
public let kBLOCKEDUSERID = "blockedUserId"

//message types
public let kPICTURE = "picture"
public let kTEXT = "text"
public let kVIDEO = "video"
public let kAUDIO = "audio"
public let kLOCATION = "location"

//coordinates
public let kLATITUDE = "latitude"
public let kLONGITUDE = "longitude"


//message status
public let kDELIVERED = "Delivered"
public let kREAD = "Read"

//push
public let kDEVICEID = "deviceId"

//backgroung color
public let kRED = "red"
public let kGREEN = "green"
public let kBLUE = "blue"
