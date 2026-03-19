// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/GetWorldPropertiesRequest
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
#include "gazebo_msgs/srv/get_world_properties.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetWorldProperties::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetWorldProperties::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetWorldProperties::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common::copy_from_struct(gazebo_msgs::srv::GetWorldProperties::Request* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetWorldProperties::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetWorldPropertiesRequest");
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetWorldProperties::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetWorldProperties::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetWorldProperties::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common::copy_from_struct(gazebo_msgs::srv::GetWorldProperties::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //sim_time
        const matlab::data::TypedArray<double> sim_time_arr = arr["sim_time"];
        msg->sim_time = sim_time_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'sim_time' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'sim_time' is wrong type; expected a double.");
    }
    try {
        //model_names
        const matlab::data::CellArray model_names_cellarr = arr["model_names"];
        size_t nelem = model_names_cellarr.getNumberOfElements();
        for (size_t idx=0; idx < nelem; ++idx){
        	const matlab::data::CharArray model_names_arr = model_names_cellarr[idx];
        	msg->model_names.push_back(model_names_arr.toAscii());
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'model_names' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'model_names' is wrong type; expected a string.");
    }
    try {
        //rendering_enabled
        const matlab::data::TypedArray<bool> rendering_enabled_arr = arr["rendering_enabled"];
        msg->rendering_enabled = rendering_enabled_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'rendering_enabled' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'rendering_enabled' is wrong type; expected a logical.");
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
  MDArray_T ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetWorldProperties::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","sim_time","model_names","rendering_enabled","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetWorldPropertiesResponse");
    // sim_time
    auto currentElement_sim_time = (msg + ctr)->sim_time;
    outArray[ctr]["sim_time"] = factory.createScalar(currentElement_sim_time);
    // model_names
    auto currentElement_model_names = (msg + ctr)->model_names;
    auto model_namesoutCell = factory.createCellArray({currentElement_model_names.size(),1});
    for(size_t idxin = 0; idxin < currentElement_model_names.size(); ++ idxin){
    	model_namesoutCell[idxin] = factory.createCharArray(currentElement_model_names[idxin]);
    }
    outArray[ctr]["model_names"] = model_namesoutCell;
    // rendering_enabled
    auto currentElement_rendering_enabled = (msg + ctr)->rendering_enabled;
    outArray[ctr]["rendering_enabled"] = factory.createScalar(currentElement_rendering_enabled);
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_GetWorldProperties_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_GetWorldProperties_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_GetWorldProperties_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetWorldProperties::Request,ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetWorldProperties::Response,ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_GetWorldProperties_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetWorldProperties::Request,ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetWorldProperties::Response,ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_GetWorldProperties_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::GetWorldProperties::Request>();
        ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::GetWorldProperties::Response>();
        ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_GetWorldProperties_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::GetWorldProperties,gazebo_msgs::srv::GetWorldProperties::Request,gazebo_msgs::srv::GetWorldProperties::Response,ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common,ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_GetWorldProperties_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::GetWorldProperties,gazebo_msgs::srv::GetWorldProperties::Request,gazebo_msgs::srv::GetWorldProperties::Response,ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common,ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common,rclcpp::Client<gazebo_msgs::srv::GetWorldProperties>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_GetWorldProperties_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetWorldProperties::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetWorldProperties::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetWorldPropertiesRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetWorldProperties::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetWorldPropertiesResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetWorldProperties::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_GetWorldProperties_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
