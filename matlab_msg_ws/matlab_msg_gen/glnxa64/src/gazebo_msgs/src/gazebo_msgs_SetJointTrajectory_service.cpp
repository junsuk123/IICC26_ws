// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/SetJointTrajectoryRequest
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
#include "gazebo_msgs/srv/set_joint_trajectory.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::SetJointTrajectory::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::SetJointTrajectory::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetJointTrajectory::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common::copy_from_struct(gazebo_msgs::srv::SetJointTrajectory::Request* msg, const matlab::data::Struct& arr,
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
        //joint_trajectory
        const matlab::data::StructArray joint_trajectory_arr = arr["joint_trajectory"];
        auto msgClassPtr_joint_trajectory = getCommonObject<trajectory_msgs::msg::JointTrajectory>("ros2_trajectory_msgs_msg_JointTrajectory_common",loader);
        msgClassPtr_joint_trajectory->copy_from_struct(&msg->joint_trajectory,joint_trajectory_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'joint_trajectory' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'joint_trajectory' is wrong type; expected a struct.");
    }
    try {
        //model_pose
        const matlab::data::StructArray model_pose_arr = arr["model_pose"];
        auto msgClassPtr_model_pose = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
        msgClassPtr_model_pose->copy_from_struct(&msg->model_pose,model_pose_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'model_pose' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'model_pose' is wrong type; expected a struct.");
    }
    try {
        //set_model_pose
        const matlab::data::TypedArray<bool> set_model_pose_arr = arr["set_model_pose"];
        msg->set_model_pose = set_model_pose_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'set_model_pose' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'set_model_pose' is wrong type; expected a logical.");
    }
    try {
        //disable_physics_updates
        const matlab::data::TypedArray<bool> disable_physics_updates_arr = arr["disable_physics_updates"];
        msg->disable_physics_updates = disable_physics_updates_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'disable_physics_updates' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'disable_physics_updates' is wrong type; expected a logical.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetJointTrajectory::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","model_name","joint_trajectory","model_pose","set_model_pose","disable_physics_updates"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SetJointTrajectoryRequest");
    // model_name
    auto currentElement_model_name = (msg + ctr)->model_name;
    outArray[ctr]["model_name"] = factory.createCharArray(currentElement_model_name);
    // joint_trajectory
    auto currentElement_joint_trajectory = (msg + ctr)->joint_trajectory;
    auto msgClassPtr_joint_trajectory = getCommonObject<trajectory_msgs::msg::JointTrajectory>("ros2_trajectory_msgs_msg_JointTrajectory_common",loader);
    outArray[ctr]["joint_trajectory"] = msgClassPtr_joint_trajectory->get_arr(factory, &currentElement_joint_trajectory, loader);
    // model_pose
    auto currentElement_model_pose = (msg + ctr)->model_pose;
    auto msgClassPtr_model_pose = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
    outArray[ctr]["model_pose"] = msgClassPtr_model_pose->get_arr(factory, &currentElement_model_pose, loader);
    // set_model_pose
    auto currentElement_set_model_pose = (msg + ctr)->set_model_pose;
    outArray[ctr]["set_model_pose"] = factory.createScalar(currentElement_set_model_pose);
    // disable_physics_updates
    auto currentElement_disable_physics_updates = (msg + ctr)->disable_physics_updates;
    outArray[ctr]["disable_physics_updates"] = factory.createScalar(currentElement_disable_physics_updates);
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::SetJointTrajectory::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::SetJointTrajectory::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetJointTrajectory::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common::copy_from_struct(gazebo_msgs::srv::SetJointTrajectory::Response* msg, const matlab::data::Struct& arr,
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
  MDArray_T ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetJointTrajectory::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SetJointTrajectoryResponse");
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_SetJointTrajectory_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_SetJointTrajectory_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_SetJointTrajectory_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::SetJointTrajectory::Request,ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::SetJointTrajectory::Response,ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_SetJointTrajectory_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::SetJointTrajectory::Request,ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::SetJointTrajectory::Response,ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_SetJointTrajectory_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::SetJointTrajectory::Request>();
        ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::SetJointTrajectory::Response>();
        ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_SetJointTrajectory_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::SetJointTrajectory,gazebo_msgs::srv::SetJointTrajectory::Request,gazebo_msgs::srv::SetJointTrajectory::Response,ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common,ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_SetJointTrajectory_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::SetJointTrajectory,gazebo_msgs::srv::SetJointTrajectory::Request,gazebo_msgs::srv::SetJointTrajectory::Response,ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common,ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common,rclcpp::Client<gazebo_msgs::srv::SetJointTrajectory>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_SetJointTrajectory_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::SetJointTrajectory::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::SetJointTrajectory::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SetJointTrajectoryRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::SetJointTrajectory::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SetJointTrajectoryResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::SetJointTrajectory::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_SetJointTrajectory_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
