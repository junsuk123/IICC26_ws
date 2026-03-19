// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/GetLinkPropertiesRequest
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4100)
#pragma warning(disable : 4265)
#pragma warning(disable : 4456)
#pragma warning(disable : 4458)
#pragma warning(disable : 4946)
#pragma warning(disable : 4244)
#else
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
#pragma GCC diagnostic ignored "-Wunused-local-typedefs"
#pragma GCC diagnostic ignored "-Wredundant-decls"
#pragma GCC diagnostic ignored "-Wnon-virtual-dtor"
#pragma GCC diagnostic ignored "-Wdelete-non-virtual-dtor"
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wshadow"
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#endif //_MSC_VER
#include "rclcpp/rclcpp.hpp"
#include "gazebo_msgs/srv/get_link_properties.hpp"
#include "visibility_control.h"
#ifndef FOUNDATION_MATLABDATA_API
#include "MDArray.hpp"
#include "StructArray.hpp"
#include "TypedArrayRef.hpp"
#include "Struct.hpp"
#include "ArrayFactory.hpp"
#include "StructRef.hpp"
#include "Reference.hpp"
#endif
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
#include "ROS2ServiceTemplates.hpp"
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetLinkProperties::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetLinkProperties::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetLinkProperties::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common::copy_from_struct(gazebo_msgs::srv::GetLinkProperties::Request* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //link_name
        const matlab::data::CharArray link_name_arr = arr["link_name"];
        msg->link_name = link_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'link_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'link_name' is wrong type; expected a string.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetLinkProperties::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","link_name"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetLinkPropertiesRequest");
    // link_name
    auto currentElement_link_name = (msg + ctr)->link_name;
    outArray[ctr]["link_name"] = factory.createCharArray(currentElement_link_name);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetLinkProperties::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetLinkProperties::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetLinkProperties::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common::copy_from_struct(gazebo_msgs::srv::GetLinkProperties::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //com
        const matlab::data::StructArray com_arr = arr["com"];
        auto msgClassPtr_com = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
        msgClassPtr_com->copy_from_struct(&msg->com,com_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'com' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'com' is wrong type; expected a struct.");
    }
    try {
        //gravity_mode
        const matlab::data::TypedArray<bool> gravity_mode_arr = arr["gravity_mode"];
        msg->gravity_mode = gravity_mode_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'gravity_mode' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'gravity_mode' is wrong type; expected a logical.");
    }
    try {
        //mass
        const matlab::data::TypedArray<double> mass_arr = arr["mass"];
        msg->mass = mass_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'mass' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'mass' is wrong type; expected a double.");
    }
    try {
        //ixx
        const matlab::data::TypedArray<double> ixx_arr = arr["ixx"];
        msg->ixx = ixx_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'ixx' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'ixx' is wrong type; expected a double.");
    }
    try {
        //ixy
        const matlab::data::TypedArray<double> ixy_arr = arr["ixy"];
        msg->ixy = ixy_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'ixy' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'ixy' is wrong type; expected a double.");
    }
    try {
        //ixz
        const matlab::data::TypedArray<double> ixz_arr = arr["ixz"];
        msg->ixz = ixz_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'ixz' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'ixz' is wrong type; expected a double.");
    }
    try {
        //iyy
        const matlab::data::TypedArray<double> iyy_arr = arr["iyy"];
        msg->iyy = iyy_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'iyy' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'iyy' is wrong type; expected a double.");
    }
    try {
        //iyz
        const matlab::data::TypedArray<double> iyz_arr = arr["iyz"];
        msg->iyz = iyz_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'iyz' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'iyz' is wrong type; expected a double.");
    }
    try {
        //izz
        const matlab::data::TypedArray<double> izz_arr = arr["izz"];
        msg->izz = izz_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'izz' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'izz' is wrong type; expected a double.");
    }
    try {
        //success
        const matlab::data::TypedArray<bool> success_arr = arr["success"];
        msg->success = success_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'success' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'success' is wrong type; expected a logical.");
    }
    try {
        //status_message
        const matlab::data::CharArray status_message_arr = arr["status_message"];
        msg->status_message = status_message_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'status_message' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'status_message' is wrong type; expected a string.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetLinkProperties::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","com","gravity_mode","mass","ixx","ixy","ixz","iyy","iyz","izz","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetLinkPropertiesResponse");
    // com
    auto currentElement_com = (msg + ctr)->com;
    auto msgClassPtr_com = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
    outArray[ctr]["com"] = msgClassPtr_com->get_arr(factory, &currentElement_com, loader);
    // gravity_mode
    auto currentElement_gravity_mode = (msg + ctr)->gravity_mode;
    outArray[ctr]["gravity_mode"] = factory.createScalar(currentElement_gravity_mode);
    // mass
    auto currentElement_mass = (msg + ctr)->mass;
    outArray[ctr]["mass"] = factory.createScalar(currentElement_mass);
    // ixx
    auto currentElement_ixx = (msg + ctr)->ixx;
    outArray[ctr]["ixx"] = factory.createScalar(currentElement_ixx);
    // ixy
    auto currentElement_ixy = (msg + ctr)->ixy;
    outArray[ctr]["ixy"] = factory.createScalar(currentElement_ixy);
    // ixz
    auto currentElement_ixz = (msg + ctr)->ixz;
    outArray[ctr]["ixz"] = factory.createScalar(currentElement_ixz);
    // iyy
    auto currentElement_iyy = (msg + ctr)->iyy;
    outArray[ctr]["iyy"] = factory.createScalar(currentElement_iyy);
    // iyz
    auto currentElement_iyz = (msg + ctr)->iyz;
    outArray[ctr]["iyz"] = factory.createScalar(currentElement_iyz);
    // izz
    auto currentElement_izz = (msg + ctr)->izz;
    outArray[ctr]["izz"] = factory.createScalar(currentElement_izz);
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_GetLinkProperties_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_GetLinkProperties_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_GetLinkProperties_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetLinkProperties::Request,ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetLinkProperties::Response,ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_GetLinkProperties_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetLinkProperties::Request,ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetLinkProperties::Response,ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_GetLinkProperties_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::GetLinkProperties::Request>();
        ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::GetLinkProperties::Response>();
        ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_GetLinkProperties_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::GetLinkProperties,gazebo_msgs::srv::GetLinkProperties::Request,gazebo_msgs::srv::GetLinkProperties::Response,ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common,ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_GetLinkProperties_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::GetLinkProperties,gazebo_msgs::srv::GetLinkProperties::Request,gazebo_msgs::srv::GetLinkProperties::Response,ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common,ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common,rclcpp::Client<gazebo_msgs::srv::GetLinkProperties>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_GetLinkProperties_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetLinkProperties::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetLinkProperties::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetLinkPropertiesRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetLinkProperties::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetLinkPropertiesResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetLinkProperties::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_GetLinkProperties_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
