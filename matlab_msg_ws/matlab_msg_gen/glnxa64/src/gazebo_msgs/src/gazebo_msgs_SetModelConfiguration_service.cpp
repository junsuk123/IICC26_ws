// Copyright 2021-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/SetModelConfigurationRequest
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
#include "gazebo_msgs/srv/set_model_configuration.hpp"
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
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::SetModelConfiguration::Request> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::SetModelConfiguration::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetModelConfiguration::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common::copy_from_struct(gazebo_msgs::srv::SetModelConfiguration::Request* msg, const matlab::data::Struct& arr,
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
        //urdf_param_name
        const matlab::data::CharArray urdf_param_name_arr = arr["urdf_param_name"];
        msg->urdf_param_name = urdf_param_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'urdf_param_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'urdf_param_name' is wrong type; expected a string.");
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
        //joint_positions
        const matlab::data::TypedArray<double> joint_positions_arr = arr["joint_positions"];
        size_t nelem = joint_positions_arr.getNumberOfElements();
        	msg->joint_positions.resize(nelem);
        	std::copy(joint_positions_arr.begin(), joint_positions_arr.begin()+nelem, msg->joint_positions.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'joint_positions' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'joint_positions' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetModelConfiguration::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","model_name","urdf_param_name","joint_names","joint_positions"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SetModelConfigurationRequest");
    // model_name
    auto currentElement_model_name = (msg + ctr)->model_name;
    outArray[ctr]["model_name"] = factory.createCharArray(currentElement_model_name);
    // urdf_param_name
    auto currentElement_urdf_param_name = (msg + ctr)->urdf_param_name;
    outArray[ctr]["urdf_param_name"] = factory.createCharArray(currentElement_urdf_param_name);
    // joint_names
    auto currentElement_joint_names = (msg + ctr)->joint_names;
    auto joint_namesoutCell = factory.createCellArray({currentElement_joint_names.size(),1});
    for(size_t idxin = 0; idxin < currentElement_joint_names.size(); ++ idxin){
    	joint_namesoutCell[idxin] = factory.createCharArray(currentElement_joint_names[idxin]);
    }
    outArray[ctr]["joint_names"] = joint_namesoutCell;
    // joint_positions
    auto currentElement_joint_positions = (msg + ctr)->joint_positions;
    outArray[ctr]["joint_positions"] = factory.createArray<gazebo_msgs::srv::SetModelConfiguration::Request::_joint_positions_type::const_iterator, double>({currentElement_joint_positions.size(), 1}, currentElement_joint_positions.begin(), currentElement_joint_positions.end());
    }
    return std::move(outArray);
  }
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common : public MATLABROS2MsgInterface<gazebo_msgs::srv::SetModelConfiguration::Response> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common(){}
    virtual void copy_from_struct(gazebo_msgs::srv::SetModelConfiguration::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetModelConfiguration::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common::copy_from_struct(gazebo_msgs::srv::SetModelConfiguration::Response* msg, const matlab::data::Struct& arr,
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
  MDArray_T ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common::get_arr(MDFactory_T& factory, const gazebo_msgs::srv::SetModelConfiguration::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","success","status_message"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SetModelConfigurationResponse");
    // success
    auto currentElement_success = (msg + ctr)->success;
    outArray[ctr]["success"] = factory.createScalar(currentElement_success);
    // status_message
    auto currentElement_status_message = (msg + ctr)->status_message;
    outArray[ctr]["status_message"] = factory.createCharArray(currentElement_status_message);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_SetModelConfiguration_service : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_SetModelConfiguration_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_SetModelConfiguration_service::generatePublisherInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::SetModelConfiguration::Request,ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2PublisherImpl<gazebo_msgs::srv::SetModelConfiguration::Response,ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          ros2_gazebo_msgs_SetModelConfiguration_service::generateSubscriberInterface(ElementType type){
    if(type == eRequest){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::SetModelConfiguration::Request,ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common>>();
    }else if(type == eResponse){
        return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::srv::SetModelConfiguration::Response,ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<void> ros2_gazebo_msgs_SetModelConfiguration_service::generateCppMessage(ElementType type, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
        auto msg = std::make_shared<gazebo_msgs::srv::SetModelConfiguration::Request>();
        ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else if(type == eResponse){
        auto msg = std::make_shared<gazebo_msgs::srv::SetModelConfiguration::Response>();
        ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common commonObj;
        commonObj.mCommonObjMap = commonObjMap;
        commonObj.copy_from_struct(msg.get(), arr[0], loader);
        return msg;
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          ros2_gazebo_msgs_SetModelConfiguration_service::generateSvcServerInterface(){
    return std::make_shared<ROS2SvcServerImpl<gazebo_msgs::srv::SetModelConfiguration,gazebo_msgs::srv::SetModelConfiguration::Request,gazebo_msgs::srv::SetModelConfiguration::Response,ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common,ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          ros2_gazebo_msgs_SetModelConfiguration_service::generateSvcClientInterface(){
    return std::make_shared<ROS2SvcClientImpl<gazebo_msgs::srv::SetModelConfiguration,gazebo_msgs::srv::SetModelConfiguration::Request,gazebo_msgs::srv::SetModelConfiguration::Response,ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common,ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common,rclcpp::Client<gazebo_msgs::srv::SetModelConfiguration>::SharedFuture>>();
  }
  matlab::data::StructArray ros2_gazebo_msgs_SetModelConfiguration_service::generateMLMessage(ElementType type, 
                                                    void*  msgPtr ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    if(type == eRequest){
	    ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::SetModelConfiguration::Request*)msgPtr, loader);
    }else if(type == eResponse){
        ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common commonObj;	
        commonObj.mCommonObjMap = commonObjMap;	
	    MDFactory_T factory;
	    return commonObj.get_arr(factory, (gazebo_msgs::srv::SetModelConfiguration::Response*)msgPtr, loader);
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
  }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SetModelConfigurationRequest_common, MATLABROS2MsgInterface<gazebo_msgs::srv::SetModelConfiguration::Request>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SetModelConfigurationResponse_common, MATLABROS2MsgInterface<gazebo_msgs::srv::SetModelConfiguration::Response>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_SetModelConfiguration_service, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
