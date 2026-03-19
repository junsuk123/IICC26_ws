// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/GetJointPropertiesRequest
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
#include "gazebo_msgs/srv/get_joint_properties.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetJointProperties::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetJointProperties::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetJointProperties::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common::copy_from_struct(gazebo_msgs::srv::GetJointProperties::Request* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //joint_name
        const matlab::data::CharArray joint_name_arr = arr["joint_name"];
        msg->joint_name = joint_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'joint_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'joint_name' is wrong type; expected a string.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetJointProperties::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","joint_name"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetJointPropertiesRequest");
    // joint_name
    auto currentElement_joint_name = (msg + ctr)->joint_name;
    outArray[ctr]["joint_name"] = factory.createCharArray(currentElement_joint_name);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetJointProperties::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetJointProperties::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetJointProperties::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common::copy_from_struct(gazebo_msgs::srv::GetJointProperties::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //type
        const matlab::data::TypedArray<uint8_t> type_arr = arr["type"];
        msg->type = type_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'type' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'type' is wrong type; expected a uint8.");
    }
    try {
        //damping
        const matlab::data::TypedArray<double> damping_arr = arr["damping"];
        size_t nelem = damping_arr.getNumberOfElements();
        	msg->damping.resize(nelem);
        	std::copy(damping_arr.begin(), damping_arr.begin()+nelem, msg->damping.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'damping' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'damping' is wrong type; expected a double.");
    }
    try {
        //position
        const matlab::data::TypedArray<double> position_arr = arr["position"];
        size_t nelem = position_arr.getNumberOfElements();
        	msg->position.resize(nelem);
        	std::copy(position_arr.begin(), position_arr.begin()+nelem, msg->position.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'position' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'position' is wrong type; expected a double.");
    }
    try {
        //rate
        const matlab::data::TypedArray<double> rate_arr = arr["rate"];
        size_t nelem = rate_arr.getNumberOfElements();
        	msg->rate.resize(nelem);
        	std::copy(rate_arr.begin(), rate_arr.begin()+nelem, msg->rate.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'rate' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'rate' is wrong type; expected a double.");
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
  MDArray_T ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetJointProperties::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","type","REVOLUTE","CONTINUOUS","PRISMATIC","FIXED","BALL","UNIVERSAL","damping","position","rate","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetJointPropertiesResponse");
    // type
    auto currentElement_type = (msg + ctr)->type;
    outArray[ctr]["type"] = factory.createScalar(currentElement_type);
    // REVOLUTE
    auto currentElement_REVOLUTE = (msg + ctr)->REVOLUTE;
    outArray[ctr]["REVOLUTE"] = factory.createScalar(currentElement_REVOLUTE);
    // CONTINUOUS
    auto currentElement_CONTINUOUS = (msg + ctr)->CONTINUOUS;
    outArray[ctr]["CONTINUOUS"] = factory.createScalar(currentElement_CONTINUOUS);
    // PRISMATIC
    auto currentElement_PRISMATIC = (msg + ctr)->PRISMATIC;
    outArray[ctr]["PRISMATIC"] = factory.createScalar(currentElement_PRISMATIC);
    // FIXED
    auto currentElement_FIXED = (msg + ctr)->FIXED;
    outArray[ctr]["FIXED"] = factory.createScalar(currentElement_FIXED);
    // BALL
    auto currentElement_BALL = (msg + ctr)->BALL;
    outArray[ctr]["BALL"] = factory.createScalar(currentElement_BALL);
    // UNIVERSAL
    auto currentElement_UNIVERSAL = (msg + ctr)->UNIVERSAL;
    outArray[ctr]["UNIVERSAL"] = factory.createScalar(currentElement_UNIVERSAL);
    // damping
    auto currentElement_damping = (msg + ctr)->damping;
    outArray[ctr]["damping"] = factory.createArray<gazebo_msgs::srv::GetJointProperties::Response::_damping_type::const_iterator, double>({currentElement_damping.size(), 1}, currentElement_damping.begin(), currentElement_damping.end());
    // position
    auto currentElement_position = (msg + ctr)->position;
    outArray[ctr]["position"] = factory.createArray<gazebo_msgs::srv::GetJointProperties::Response::_position_type::const_iterator, double>({currentElement_position.size(), 1}, currentElement_position.begin(), currentElement_position.end());
    // rate
    auto currentElement_rate = (msg + ctr)->rate;
    outArray[ctr]["rate"] = factory.createArray<gazebo_msgs::srv::GetJointProperties::Response::_rate_type::const_iterator, double>({currentElement_rate.size(), 1}, currentElement_rate.begin(), currentElement_rate.end());
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_GetJointProperties_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_GetJointProperties_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_GetJointProperties_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetJointProperties::Request,ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetJointProperties::Response,ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_GetJointProperties_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetJointProperties::Request,ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetJointProperties::Response,ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_GetJointProperties_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::GetJointProperties::Request>();
        ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::GetJointProperties::Response>();
        ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_GetJointProperties_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::GetJointProperties,gazebo_msgs::srv::GetJointProperties::Request,gazebo_msgs::srv::GetJointProperties::Response,ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common,ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_GetJointProperties_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::GetJointProperties,gazebo_msgs::srv::GetJointProperties::Request,gazebo_msgs::srv::GetJointProperties::Response,ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common,ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common,rclcpp::Client<gazebo_msgs::srv::GetJointProperties>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_GetJointProperties_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetJointProperties::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetJointProperties::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetJointPropertiesRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetJointProperties::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetJointPropertiesResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetJointProperties::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_GetJointProperties_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
