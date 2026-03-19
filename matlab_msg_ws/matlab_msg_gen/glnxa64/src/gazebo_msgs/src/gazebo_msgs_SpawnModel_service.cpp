// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/SpawnModelRequest
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
#include "gazebo_msgs/srv/spawn_model.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SpawnModelRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::SpawnModel::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SpawnModelRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::SpawnModel::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SpawnModel::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SpawnModelRequest_common::copy_from_struct(gazebo_msgs::srv::SpawnModel::Request* msg, const matlab::data::Struct& arr,
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
        //model_xml
        const matlab::data::CharArray model_xml_arr = arr["model_xml"];
        msg->model_xml = model_xml_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'model_xml' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'model_xml' is wrong type; expected a string.");
    }
    try {
        //robot_namespace
        const matlab::data::CharArray robot_namespace_arr = arr["robot_namespace"];
        msg->robot_namespace = robot_namespace_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'robot_namespace' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'robot_namespace' is wrong type; expected a string.");
    }
    try {
        //initial_pose
        const matlab::data::StructArray initial_pose_arr = arr["initial_pose"];
        auto msgClassPtr_initial_pose = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
        msgClassPtr_initial_pose->copy_from_struct(&msg->initial_pose,initial_pose_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'initial_pose' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'initial_pose' is wrong type; expected a struct.");
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
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_SpawnModelRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SpawnModel::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","model_name","model_xml","robot_namespace","initial_pose","reference_frame"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SpawnModelRequest");
    // model_name
    auto currentElement_model_name = (msg + ctr)->model_name;
    outArray[ctr]["model_name"] = factory.createCharArray(currentElement_model_name);
    // model_xml
    auto currentElement_model_xml = (msg + ctr)->model_xml;
    outArray[ctr]["model_xml"] = factory.createCharArray(currentElement_model_xml);
    // robot_namespace
    auto currentElement_robot_namespace = (msg + ctr)->robot_namespace;
    outArray[ctr]["robot_namespace"] = factory.createCharArray(currentElement_robot_namespace);
    // initial_pose
    auto currentElement_initial_pose = (msg + ctr)->initial_pose;
    auto msgClassPtr_initial_pose = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
    outArray[ctr]["initial_pose"] = msgClassPtr_initial_pose->get_arr(factory, &currentElement_initial_pose, loader);
    // reference_frame
    auto currentElement_reference_frame = (msg + ctr)->reference_frame;
    outArray[ctr]["reference_frame"] = factory.createCharArray(currentElement_reference_frame);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SpawnModelResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::SpawnModel::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SpawnModelResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::SpawnModel::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SpawnModel::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SpawnModelResponse_common::copy_from_struct(gazebo_msgs::srv::SpawnModel::Response* msg, const matlab::data::Struct& arr,
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
  MDArray_T ros2_gazebo_msgs_msg_SpawnModelResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SpawnModel::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SpawnModelResponse");
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_SpawnModel_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_SpawnModel_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_SpawnModel_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::SpawnModel::Request,ros2_gazebo_msgs_msg_SpawnModelRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::SpawnModel::Response,ros2_gazebo_msgs_msg_SpawnModelResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_SpawnModel_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::SpawnModel::Request,ros2_gazebo_msgs_msg_SpawnModelRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::SpawnModel::Response,ros2_gazebo_msgs_msg_SpawnModelResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_SpawnModel_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::SpawnModel::Request>();
        ros2_gazebo_msgs_msg_SpawnModelRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::SpawnModel::Response>();
        ros2_gazebo_msgs_msg_SpawnModelResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_SpawnModel_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::SpawnModel,gazebo_msgs::srv::SpawnModel::Request,gazebo_msgs::srv::SpawnModel::Response,ros2_gazebo_msgs_msg_SpawnModelRequest_common,ros2_gazebo_msgs_msg_SpawnModelResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_SpawnModel_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::SpawnModel,gazebo_msgs::srv::SpawnModel::Request,gazebo_msgs::srv::SpawnModel::Response,ros2_gazebo_msgs_msg_SpawnModelRequest_common,ros2_gazebo_msgs_msg_SpawnModelResponse_common,rclcpp::Client<gazebo_msgs::srv::SpawnModel>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_SpawnModel_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_SpawnModelRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::SpawnModel::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_SpawnModelResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::SpawnModel::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SpawnModelRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::SpawnModel::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SpawnModelResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::SpawnModel::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_SpawnModel_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
