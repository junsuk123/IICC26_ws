// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/BodyRequestRequest
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
#include "gazebo_msgs/srv/body_request.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_BodyRequestRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::BodyRequest::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_BodyRequestRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::BodyRequest::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::BodyRequest::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_BodyRequestRequest_common::copy_from_struct(gazebo_msgs::srv::BodyRequest::Request* msg, const matlab::data::Struct& arr,
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
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_BodyRequestRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::BodyRequest::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","body_name"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/BodyRequestRequest");
    // body_name
    auto currentElement_body_name = (msg + ctr)->body_name;
    outArray[ctr]["body_name"] = factory.createCharArray(currentElement_body_name);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_BodyRequestResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::BodyRequest::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_BodyRequestResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::BodyRequest::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::BodyRequest::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_BodyRequestResponse_common::copy_from_struct(gazebo_msgs::srv::BodyRequest::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_BodyRequestResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::BodyRequest::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/BodyRequestResponse");
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_BodyRequest_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_BodyRequest_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_BodyRequest_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::BodyRequest::Request,ros2_gazebo_msgs_msg_BodyRequestRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::BodyRequest::Response,ros2_gazebo_msgs_msg_BodyRequestResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_BodyRequest_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::BodyRequest::Request,ros2_gazebo_msgs_msg_BodyRequestRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::BodyRequest::Response,ros2_gazebo_msgs_msg_BodyRequestResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_BodyRequest_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::BodyRequest::Request>();
        ros2_gazebo_msgs_msg_BodyRequestRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::BodyRequest::Response>();
        ros2_gazebo_msgs_msg_BodyRequestResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_BodyRequest_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::BodyRequest,gazebo_msgs::srv::BodyRequest::Request,gazebo_msgs::srv::BodyRequest::Response,ros2_gazebo_msgs_msg_BodyRequestRequest_common,ros2_gazebo_msgs_msg_BodyRequestResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_BodyRequest_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::BodyRequest,gazebo_msgs::srv::BodyRequest::Request,gazebo_msgs::srv::BodyRequest::Response,ros2_gazebo_msgs_msg_BodyRequestRequest_common,ros2_gazebo_msgs_msg_BodyRequestResponse_common,rclcpp::Client<gazebo_msgs::srv::BodyRequest>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_BodyRequest_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_BodyRequestRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::BodyRequest::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_BodyRequestResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::BodyRequest::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_BodyRequestRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::BodyRequest::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_BodyRequestResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::BodyRequest::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_BodyRequest_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
