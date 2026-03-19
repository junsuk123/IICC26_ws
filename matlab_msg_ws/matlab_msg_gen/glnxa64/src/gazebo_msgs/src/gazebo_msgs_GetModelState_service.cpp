// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/GetModelStateRequest
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
#include "gazebo_msgs/srv/get_model_state.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetModelStateRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetModelState::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetModelStateRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetModelState::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetModelState::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetModelStateRequest_common::copy_from_struct(gazebo_msgs::srv::GetModelState::Request* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //model_name
        const matlab::data::CharArray model_name_arr = arr["model_name"];
        msg->model_name = model_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'model_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'model_name' is wrong type; expected a string.");
    }
    try {
        //relative_entity_name
        const matlab::data::CharArray relative_entity_name_arr = arr["relative_entity_name"];
        msg->relative_entity_name = relative_entity_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'relative_entity_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'relative_entity_name' is wrong type; expected a string.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_GetModelStateRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetModelState::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","model_name","relative_entity_name"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetModelStateRequest");
    // model_name
    auto currentElement_model_name = (msg + ctr)->model_name;
    outArray[ctr]["model_name"] = factory.createCharArray(currentElement_model_name);
    // relative_entity_name
    auto currentElement_relative_entity_name = (msg + ctr)->relative_entity_name;
    outArray[ctr]["relative_entity_name"] = factory.createCharArray(currentElement_relative_entity_name);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetModelStateResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetModelState::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetModelStateResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetModelState::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetModelState::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetModelStateResponse_common::copy_from_struct(gazebo_msgs::srv::GetModelState::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //header
        const matlab::data::StructArray header_arr = arr["header"];
        auto msgClassPtr_header = getCommonObject<std_msgs::msg::Header>("ros2_std_msgs_msg_Header_common",loader);
        msgClassPtr_header->copy_from_struct(&msg->header,header_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'header' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'header' is wrong type; expected a struct.");
    }
    try {
        //pose
        const matlab::data::StructArray pose_arr = arr["pose"];
        auto msgClassPtr_pose = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
        msgClassPtr_pose->copy_from_struct(&msg->pose,pose_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'pose' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'pose' is wrong type; expected a struct.");
    }
    try {
        //twist
        const matlab::data::StructArray twist_arr = arr["twist"];
        auto msgClassPtr_twist = getCommonObject<geometry_msgs::msg::Twist>("ros2_geometry_msgs_msg_Twist_common",loader);
        msgClassPtr_twist->copy_from_struct(&msg->twist,twist_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'twist' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'twist' is wrong type; expected a struct.");
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
  MDArray_T ros2_gazebo_msgs_msg_GetModelStateResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetModelState::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","header","pose","twist","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetModelStateResponse");
    // header
    auto currentElement_header = (msg + ctr)->header;
    auto msgClassPtr_header = getCommonObject<std_msgs::msg::Header>("ros2_std_msgs_msg_Header_common",loader);
    outArray[ctr]["header"] = msgClassPtr_header->get_arr(factory, &currentElement_header, loader);
    // pose
    auto currentElement_pose = (msg + ctr)->pose;
    auto msgClassPtr_pose = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
    outArray[ctr]["pose"] = msgClassPtr_pose->get_arr(factory, &currentElement_pose, loader);
    // twist
    auto currentElement_twist = (msg + ctr)->twist;
    auto msgClassPtr_twist = getCommonObject<geometry_msgs::msg::Twist>("ros2_geometry_msgs_msg_Twist_common",loader);
    outArray[ctr]["twist"] = msgClassPtr_twist->get_arr(factory, &currentElement_twist, loader);
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_GetModelState_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_GetModelState_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_GetModelState_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetModelState::Request,ros2_gazebo_msgs_msg_GetModelStateRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetModelState::Response,ros2_gazebo_msgs_msg_GetModelStateResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_GetModelState_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetModelState::Request,ros2_gazebo_msgs_msg_GetModelStateRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetModelState::Response,ros2_gazebo_msgs_msg_GetModelStateResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_GetModelState_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::GetModelState::Request>();
        ros2_gazebo_msgs_msg_GetModelStateRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::GetModelState::Response>();
        ros2_gazebo_msgs_msg_GetModelStateResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_GetModelState_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::GetModelState,gazebo_msgs::srv::GetModelState::Request,gazebo_msgs::srv::GetModelState::Response,ros2_gazebo_msgs_msg_GetModelStateRequest_common,ros2_gazebo_msgs_msg_GetModelStateResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_GetModelState_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::GetModelState,gazebo_msgs::srv::GetModelState::Request,gazebo_msgs::srv::GetModelState::Response,ros2_gazebo_msgs_msg_GetModelStateRequest_common,ros2_gazebo_msgs_msg_GetModelStateResponse_common,rclcpp::Client<gazebo_msgs::srv::GetModelState>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_GetModelState_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_GetModelStateRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetModelState::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_GetModelStateResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetModelState::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetModelStateRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetModelState::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetModelStateResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetModelState::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_GetModelState_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
