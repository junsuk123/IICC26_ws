// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/SetLightPropertiesRequest
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
#include "gazebo_msgs/srv/set_light_properties.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::SetLightProperties::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::SetLightProperties::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetLightProperties::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common::copy_from_struct(gazebo_msgs::srv::SetLightProperties::Request* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //light_name
        const matlab::data::CharArray light_name_arr = arr["light_name"];
        msg->light_name = light_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'light_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'light_name' is wrong type; expected a string.");
    }
    try {
        //diffuse
        const matlab::data::StructArray diffuse_arr = arr["diffuse"];
        auto msgClassPtr_diffuse = getCommonObject<std_msgs::msg::ColorRGBA>("ros2_std_msgs_msg_ColorRGBA_common",loader);
        msgClassPtr_diffuse->copy_from_struct(&msg->diffuse,diffuse_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'diffuse' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'diffuse' is wrong type; expected a struct.");
    }
    try {
        //attenuation_constant
        const matlab::data::TypedArray<double> attenuation_constant_arr = arr["attenuation_constant"];
        msg->attenuation_constant = attenuation_constant_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'attenuation_constant' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'attenuation_constant' is wrong type; expected a double.");
    }
    try {
        //attenuation_linear
        const matlab::data::TypedArray<double> attenuation_linear_arr = arr["attenuation_linear"];
        msg->attenuation_linear = attenuation_linear_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'attenuation_linear' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'attenuation_linear' is wrong type; expected a double.");
    }
    try {
        //attenuation_quadratic
        const matlab::data::TypedArray<double> attenuation_quadratic_arr = arr["attenuation_quadratic"];
        msg->attenuation_quadratic = attenuation_quadratic_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'attenuation_quadratic' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'attenuation_quadratic' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetLightProperties::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","light_name","diffuse","attenuation_constant","attenuation_linear","attenuation_quadratic"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SetLightPropertiesRequest");
    // light_name
    auto currentElement_light_name = (msg + ctr)->light_name;
    outArray[ctr]["light_name"] = factory.createCharArray(currentElement_light_name);
    // diffuse
    auto currentElement_diffuse = (msg + ctr)->diffuse;
    auto msgClassPtr_diffuse = getCommonObject<std_msgs::msg::ColorRGBA>("ros2_std_msgs_msg_ColorRGBA_common",loader);
    outArray[ctr]["diffuse"] = msgClassPtr_diffuse->get_arr(factory, &currentElement_diffuse, loader);
    // attenuation_constant
    auto currentElement_attenuation_constant = (msg + ctr)->attenuation_constant;
    outArray[ctr]["attenuation_constant"] = factory.createScalar(currentElement_attenuation_constant);
    // attenuation_linear
    auto currentElement_attenuation_linear = (msg + ctr)->attenuation_linear;
    outArray[ctr]["attenuation_linear"] = factory.createScalar(currentElement_attenuation_linear);
    // attenuation_quadratic
    auto currentElement_attenuation_quadratic = (msg + ctr)->attenuation_quadratic;
    outArray[ctr]["attenuation_quadratic"] = factory.createScalar(currentElement_attenuation_quadratic);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::SetLightProperties::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::SetLightProperties::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetLightProperties::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common::copy_from_struct(gazebo_msgs::srv::SetLightProperties::Response* msg, const matlab::data::Struct& arr,
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
  MDArray_T ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetLightProperties::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SetLightPropertiesResponse");
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_SetLightProperties_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_SetLightProperties_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_SetLightProperties_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::SetLightProperties::Request,ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::SetLightProperties::Response,ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_SetLightProperties_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::SetLightProperties::Request,ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::SetLightProperties::Response,ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_SetLightProperties_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::SetLightProperties::Request>();
        ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::SetLightProperties::Response>();
        ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_SetLightProperties_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::SetLightProperties,gazebo_msgs::srv::SetLightProperties::Request,gazebo_msgs::srv::SetLightProperties::Response,ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common,ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_SetLightProperties_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::SetLightProperties,gazebo_msgs::srv::SetLightProperties::Request,gazebo_msgs::srv::SetLightProperties::Response,ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common,ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common,rclcpp::Client<gazebo_msgs::srv::SetLightProperties>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_SetLightProperties_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::SetLightProperties::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::SetLightProperties::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SetLightPropertiesRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::SetLightProperties::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SetLightPropertiesResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::SetLightProperties::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_SetLightProperties_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
