// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/ApplyBodyWrenchRequest
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
#include "gazebo_msgs/srv/apply_body_wrench.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::ApplyBodyWrench::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::ApplyBodyWrench::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::ApplyBodyWrench::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common::copy_from_struct(gazebo_msgs::srv::ApplyBodyWrench::Request* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //body_name
        const matlab::data::CharArray body_name_arr = arr["body_name"];
        msg->body_name = body_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'body_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'body_name' is wrong type; expected a string.");
    }
    try {
        //reference_frame
        const matlab::data::CharArray reference_frame_arr = arr["reference_frame"];
        msg->reference_frame = reference_frame_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'reference_frame' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'reference_frame' is wrong type; expected a string.");
    }
    try {
        //reference_point
        const matlab::data::StructArray reference_point_arr = arr["reference_point"];
        auto msgClassPtr_reference_point = getCommonObject<geometry_msgs::msg::Point>("ros2_geometry_msgs_msg_Point_common",loader);
        msgClassPtr_reference_point->copy_from_struct(&msg->reference_point,reference_point_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'reference_point' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'reference_point' is wrong type; expected a struct.");
    }
    try {
        //wrench
        const matlab::data::StructArray wrench_arr = arr["wrench"];
        auto msgClassPtr_wrench = getCommonObject<geometry_msgs::msg::Wrench>("ros2_geometry_msgs_msg_Wrench_common",loader);
        msgClassPtr_wrench->copy_from_struct(&msg->wrench,wrench_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'wrench' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'wrench' is wrong type; expected a struct.");
    }
    try {
        //start_time
        const matlab::data::StructArray start_time_arr = arr["start_time"];
        auto msgClassPtr_start_time = getCommonObject<builtin_interfaces::msg::Time>("ros2_builtin_interfaces_msg_Time_common",loader);
        msgClassPtr_start_time->copy_from_struct(&msg->start_time,start_time_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'start_time' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'start_time' is wrong type; expected a struct.");
    }
    try {
        //duration
        const matlab::data::StructArray duration_arr = arr["duration"];
        auto msgClassPtr_duration = getCommonObject<builtin_interfaces::msg::Duration>("ros2_builtin_interfaces_msg_Duration_common",loader);
        msgClassPtr_duration->copy_from_struct(&msg->duration,duration_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'duration' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'duration' is wrong type; expected a struct.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::ApplyBodyWrench::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","body_name","reference_frame","reference_point","wrench","start_time","duration"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/ApplyBodyWrenchRequest");
    // body_name
    auto currentElement_body_name = (msg + ctr)->body_name;
    outArray[ctr]["body_name"] = factory.createCharArray(currentElement_body_name);
    // reference_frame
    auto currentElement_reference_frame = (msg + ctr)->reference_frame;
    outArray[ctr]["reference_frame"] = factory.createCharArray(currentElement_reference_frame);
    // reference_point
    auto currentElement_reference_point = (msg + ctr)->reference_point;
    auto msgClassPtr_reference_point = getCommonObject<geometry_msgs::msg::Point>("ros2_geometry_msgs_msg_Point_common",loader);
    outArray[ctr]["reference_point"] = msgClassPtr_reference_point->get_arr(factory, &currentElement_reference_point, loader);
    // wrench
    auto currentElement_wrench = (msg + ctr)->wrench;
    auto msgClassPtr_wrench = getCommonObject<geometry_msgs::msg::Wrench>("ros2_geometry_msgs_msg_Wrench_common",loader);
    outArray[ctr]["wrench"] = msgClassPtr_wrench->get_arr(factory, &currentElement_wrench, loader);
    // start_time
    auto currentElement_start_time = (msg + ctr)->start_time;
    auto msgClassPtr_start_time = getCommonObject<builtin_interfaces::msg::Time>("ros2_builtin_interfaces_msg_Time_common",loader);
    outArray[ctr]["start_time"] = msgClassPtr_start_time->get_arr(factory, &currentElement_start_time, loader);
    // duration
    auto currentElement_duration = (msg + ctr)->duration;
    auto msgClassPtr_duration = getCommonObject<builtin_interfaces::msg::Duration>("ros2_builtin_interfaces_msg_Duration_common",loader);
    outArray[ctr]["duration"] = msgClassPtr_duration->get_arr(factory, &currentElement_duration, loader);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::ApplyBodyWrench::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::ApplyBodyWrench::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::ApplyBodyWrench::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common::copy_from_struct(gazebo_msgs::srv::ApplyBodyWrench::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
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
  MDArray_T ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::ApplyBodyWrench::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/ApplyBodyWrenchResponse");
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_ApplyBodyWrench_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_ApplyBodyWrench_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_ApplyBodyWrench_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::ApplyBodyWrench::Request,ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::ApplyBodyWrench::Response,ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_ApplyBodyWrench_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::ApplyBodyWrench::Request,ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::ApplyBodyWrench::Response,ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_ApplyBodyWrench_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::ApplyBodyWrench::Request>();
        ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::ApplyBodyWrench::Response>();
        ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_ApplyBodyWrench_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::ApplyBodyWrench,gazebo_msgs::srv::ApplyBodyWrench::Request,gazebo_msgs::srv::ApplyBodyWrench::Response,ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common,ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_ApplyBodyWrench_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::ApplyBodyWrench,gazebo_msgs::srv::ApplyBodyWrench::Request,gazebo_msgs::srv::ApplyBodyWrench::Response,ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common,ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common,rclcpp::Client<gazebo_msgs::srv::ApplyBodyWrench>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_ApplyBodyWrench_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::ApplyBodyWrench::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::ApplyBodyWrench::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_ApplyBodyWrenchRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::ApplyBodyWrench::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_ApplyBodyWrenchResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::ApplyBodyWrench::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_ApplyBodyWrench_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
