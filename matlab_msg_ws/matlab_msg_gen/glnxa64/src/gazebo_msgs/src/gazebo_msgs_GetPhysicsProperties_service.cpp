// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/GetPhysicsPropertiesRequest
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
#include "gazebo_msgs/srv/get_physics_properties.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetPhysicsProperties::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetPhysicsProperties::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetPhysicsProperties::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common::copy_from_struct(gazebo_msgs::srv::GetPhysicsProperties::Request* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetPhysicsProperties::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetPhysicsPropertiesRequest");
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetPhysicsProperties::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetPhysicsProperties::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetPhysicsProperties::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common::copy_from_struct(gazebo_msgs::srv::GetPhysicsProperties::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //time_step
        const matlab::data::TypedArray<double> time_step_arr = arr["time_step"];
        msg->time_step = time_step_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'time_step' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'time_step' is wrong type; expected a double.");
    }
    try {
        //pause
        const matlab::data::TypedArray<bool> pause_arr = arr["pause"];
        msg->pause = pause_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'pause' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'pause' is wrong type; expected a logical.");
    }
    try {
        //max_update_rate
        const matlab::data::TypedArray<double> max_update_rate_arr = arr["max_update_rate"];
        msg->max_update_rate = max_update_rate_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'max_update_rate' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'max_update_rate' is wrong type; expected a double.");
    }
    try {
        //gravity
        const matlab::data::StructArray gravity_arr = arr["gravity"];
        auto msgClassPtr_gravity = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
        msgClassPtr_gravity->copy_from_struct(&msg->gravity,gravity_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'gravity' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'gravity' is wrong type; expected a struct.");
    }
    try {
        //ode_config
        const matlab::data::StructArray ode_config_arr = arr["ode_config"];
        auto msgClassPtr_ode_config = getCommonObject<gazebo_msgs::msg::ODEPhysics>("ros2_gazebo_msgs_msg_ODEPhysics_common",loader);
        msgClassPtr_ode_config->copy_from_struct(&msg->ode_config,ode_config_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'ode_config' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'ode_config' is wrong type; expected a struct.");
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
  MDArray_T ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetPhysicsProperties::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","time_step","pause","max_update_rate","gravity","ode_config","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetPhysicsPropertiesResponse");
    // time_step
    auto currentElement_time_step = (msg + ctr)->time_step;
    outArray[ctr]["time_step"] = factory.createScalar(currentElement_time_step);
    // pause
    auto currentElement_pause = (msg + ctr)->pause;
    outArray[ctr]["pause"] = factory.createScalar(currentElement_pause);
    // max_update_rate
    auto currentElement_max_update_rate = (msg + ctr)->max_update_rate;
    outArray[ctr]["max_update_rate"] = factory.createScalar(currentElement_max_update_rate);
    // gravity
    auto currentElement_gravity = (msg + ctr)->gravity;
    auto msgClassPtr_gravity = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
    outArray[ctr]["gravity"] = msgClassPtr_gravity->get_arr(factory, &currentElement_gravity, loader);
    // ode_config
    auto currentElement_ode_config = (msg + ctr)->ode_config;
    auto msgClassPtr_ode_config = getCommonObject<gazebo_msgs::msg::ODEPhysics>("ros2_gazebo_msgs_msg_ODEPhysics_common",loader);
    outArray[ctr]["ode_config"] = msgClassPtr_ode_config->get_arr(factory, &currentElement_ode_config, loader);
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_GetPhysicsProperties_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_GetPhysicsProperties_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_GetPhysicsProperties_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetPhysicsProperties::Request,ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetPhysicsProperties::Response,ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_GetPhysicsProperties_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetPhysicsProperties::Request,ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetPhysicsProperties::Response,ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_GetPhysicsProperties_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::GetPhysicsProperties::Request>();
        ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::GetPhysicsProperties::Response>();
        ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_GetPhysicsProperties_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::GetPhysicsProperties,gazebo_msgs::srv::GetPhysicsProperties::Request,gazebo_msgs::srv::GetPhysicsProperties::Response,ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common,ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_GetPhysicsProperties_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::GetPhysicsProperties,gazebo_msgs::srv::GetPhysicsProperties::Request,gazebo_msgs::srv::GetPhysicsProperties::Response,ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common,ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common,rclcpp::Client<gazebo_msgs::srv::GetPhysicsProperties>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_GetPhysicsProperties_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetPhysicsProperties::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetPhysicsProperties::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetPhysicsPropertiesRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetPhysicsProperties::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetPhysicsPropertiesResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetPhysicsProperties::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_GetPhysicsProperties_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
