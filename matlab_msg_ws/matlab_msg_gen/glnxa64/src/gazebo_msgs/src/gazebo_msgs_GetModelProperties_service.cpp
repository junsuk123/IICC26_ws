// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/GetModelPropertiesRequest
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
#include "gazebo_msgs/srv/get_model_properties.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetModelProperties::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetModelProperties::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetModelProperties::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common::copy_from_struct(gazebo_msgs::srv::GetModelProperties::Request* msg, const matlab::data::Struct& arr,
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
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetModelProperties::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","model_name"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetModelPropertiesRequest");
    // model_name
    auto currentElement_model_name = (msg + ctr)->model_name;
    outArray[ctr]["model_name"] = factory.createCharArray(currentElement_model_name);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::GetModelProperties::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::GetModelProperties::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetModelProperties::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common::copy_from_struct(gazebo_msgs::srv::GetModelProperties::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //parent_model_name
        const matlab::data::CharArray parent_model_name_arr = arr["parent_model_name"];
        msg->parent_model_name = parent_model_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'parent_model_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'parent_model_name' is wrong type; expected a string.");
    }
    try {
        //canonical_body_name
        const matlab::data::CharArray canonical_body_name_arr = arr["canonical_body_name"];
        msg->canonical_body_name = canonical_body_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'canonical_body_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'canonical_body_name' is wrong type; expected a string.");
    }
    try {
        //body_names
        const matlab::data::CellArray body_names_cellarr = arr["body_names"];
        size_t nelem = body_names_cellarr.getNumberOfElements();
        for (size_t idx=0; idx < nelem; ++idx){
        	const matlab::data::CharArray body_names_arr = body_names_cellarr[idx];
        	msg->body_names.push_back(body_names_arr.toAscii());
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'body_names' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'body_names' is wrong type; expected a string.");
    }
    try {
        //geom_names
        const matlab::data::CellArray geom_names_cellarr = arr["geom_names"];
        size_t nelem = geom_names_cellarr.getNumberOfElements();
        for (size_t idx=0; idx < nelem; ++idx){
        	const matlab::data::CharArray geom_names_arr = geom_names_cellarr[idx];
        	msg->geom_names.push_back(geom_names_arr.toAscii());
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'geom_names' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'geom_names' is wrong type; expected a string.");
    }
    try {
        //joint_names
        const matlab::data::CellArray joint_names_cellarr = arr["joint_names"];
        size_t nelem = joint_names_cellarr.getNumberOfElements();
        for (size_t idx=0; idx < nelem; ++idx){
        	const matlab::data::CharArray joint_names_arr = joint_names_cellarr[idx];
        	msg->joint_names.push_back(joint_names_arr.toAscii());
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'joint_names' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'joint_names' is wrong type; expected a string.");
    }
    try {
        //child_model_names
        const matlab::data::CellArray child_model_names_cellarr = arr["child_model_names"];
        size_t nelem = child_model_names_cellarr.getNumberOfElements();
        for (size_t idx=0; idx < nelem; ++idx){
        	const matlab::data::CharArray child_model_names_arr = child_model_names_cellarr[idx];
        	msg->child_model_names.push_back(child_model_names_arr.toAscii());
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'child_model_names' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'child_model_names' is wrong type; expected a string.");
    }
    try {
        //is_static
        const matlab::data::TypedArray<bool> is_static_arr = arr["is_static"];
        msg->is_static = is_static_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'is_static' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'is_static' is wrong type; expected a logical.");
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
  MDArray_T ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::GetModelProperties::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","parent_model_name","canonical_body_name","body_names","geom_names","joint_names","child_model_names","is_static","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/GetModelPropertiesResponse");
    // parent_model_name
    auto currentElement_parent_model_name = (msg + ctr)->parent_model_name;
    outArray[ctr]["parent_model_name"] = factory.createCharArray(currentElement_parent_model_name);
    // canonical_body_name
    auto currentElement_canonical_body_name = (msg + ctr)->canonical_body_name;
    outArray[ctr]["canonical_body_name"] = factory.createCharArray(currentElement_canonical_body_name);
    // body_names
    auto currentElement_body_names = (msg + ctr)->body_names;
    auto body_namesoutCell = factory.createCellArray({currentElement_body_names.size(),1});
    for(size_t idxin = 0; idxin < currentElement_body_names.size(); ++ idxin){
    	body_namesoutCell[idxin] = factory.createCharArray(currentElement_body_names[idxin]);
    }
    outArray[ctr]["body_names"] = body_namesoutCell;
    // geom_names
    auto currentElement_geom_names = (msg + ctr)->geom_names;
    auto geom_namesoutCell = factory.createCellArray({currentElement_geom_names.size(),1});
    for(size_t idxin = 0; idxin < currentElement_geom_names.size(); ++ idxin){
    	geom_namesoutCell[idxin] = factory.createCharArray(currentElement_geom_names[idxin]);
    }
    outArray[ctr]["geom_names"] = geom_namesoutCell;
    // joint_names
    auto currentElement_joint_names = (msg + ctr)->joint_names;
    auto joint_namesoutCell = factory.createCellArray({currentElement_joint_names.size(),1});
    for(size_t idxin = 0; idxin < currentElement_joint_names.size(); ++ idxin){
    	joint_namesoutCell[idxin] = factory.createCharArray(currentElement_joint_names[idxin]);
    }
    outArray[ctr]["joint_names"] = joint_namesoutCell;
    // child_model_names
    auto currentElement_child_model_names = (msg + ctr)->child_model_names;
    auto child_model_namesoutCell = factory.createCellArray({currentElement_child_model_names.size(),1});
    for(size_t idxin = 0; idxin < currentElement_child_model_names.size(); ++ idxin){
    	child_model_namesoutCell[idxin] = factory.createCharArray(currentElement_child_model_names[idxin]);
    }
    outArray[ctr]["child_model_names"] = child_model_namesoutCell;
    // is_static
    auto currentElement_is_static = (msg + ctr)->is_static;
    outArray[ctr]["is_static"] = factory.createScalar(currentElement_is_static);
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_GetModelProperties_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_GetModelProperties_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_GetModelProperties_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetModelProperties::Request,ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::GetModelProperties::Response,ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_GetModelProperties_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetModelProperties::Request,ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::GetModelProperties::Response,ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_GetModelProperties_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::GetModelProperties::Request>();
        ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::GetModelProperties::Response>();
        ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_GetModelProperties_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::GetModelProperties,gazebo_msgs::srv::GetModelProperties::Request,gazebo_msgs::srv::GetModelProperties::Response,ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common,ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_GetModelProperties_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::GetModelProperties,gazebo_msgs::srv::GetModelProperties::Request,gazebo_msgs::srv::GetModelProperties::Response,ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common,ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common,rclcpp::Client<gazebo_msgs::srv::GetModelProperties>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_GetModelProperties_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetModelProperties::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::GetModelProperties::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetModelPropertiesRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetModelProperties::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_GetModelPropertiesResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::GetModelProperties::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_GetModelProperties_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
