// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/ODEPhysics
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
#include "gazebo_msgs/msg/ode_physics.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_ODEPhysics_common : public MATLABROS2MsgInterface<gazebo_msgs::msg::ODEPhysics> {
  public:
    virtual ~ros2_gazebo_msgs_msg_ODEPhysics_common(){}
    virtual void copy_from_struct(gazebo_msgs::msg::ODEPhysics* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::msg::ODEPhysics* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_ODEPhysics_common::copy_from_struct(gazebo_msgs::msg::ODEPhysics* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //auto_disable_bodies
        const matlab::data::TypedArray<bool> auto_disable_bodies_arr = arr["auto_disable_bodies"];
        msg->auto_disable_bodies = auto_disable_bodies_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'auto_disable_bodies' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'auto_disable_bodies' is wrong type; expected a logical.");
    }
    try {
        //sor_pgs_precon_iters
        const matlab::data::TypedArray<uint32_t> sor_pgs_precon_iters_arr = arr["sor_pgs_precon_iters"];
        msg->sor_pgs_precon_iters = sor_pgs_precon_iters_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'sor_pgs_precon_iters' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'sor_pgs_precon_iters' is wrong type; expected a uint32.");
    }
    try {
        //sor_pgs_iters
        const matlab::data::TypedArray<uint32_t> sor_pgs_iters_arr = arr["sor_pgs_iters"];
        msg->sor_pgs_iters = sor_pgs_iters_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'sor_pgs_iters' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'sor_pgs_iters' is wrong type; expected a uint32.");
    }
    try {
        //sor_pgs_w
        const matlab::data::TypedArray<double> sor_pgs_w_arr = arr["sor_pgs_w"];
        msg->sor_pgs_w = sor_pgs_w_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'sor_pgs_w' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'sor_pgs_w' is wrong type; expected a double.");
    }
    try {
        //sor_pgs_rms_error_tol
        const matlab::data::TypedArray<double> sor_pgs_rms_error_tol_arr = arr["sor_pgs_rms_error_tol"];
        msg->sor_pgs_rms_error_tol = sor_pgs_rms_error_tol_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'sor_pgs_rms_error_tol' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'sor_pgs_rms_error_tol' is wrong type; expected a double.");
    }
    try {
        //contact_surface_layer
        const matlab::data::TypedArray<double> contact_surface_layer_arr = arr["contact_surface_layer"];
        msg->contact_surface_layer = contact_surface_layer_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'contact_surface_layer' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'contact_surface_layer' is wrong type; expected a double.");
    }
    try {
        //contact_max_correcting_vel
        const matlab::data::TypedArray<double> contact_max_correcting_vel_arr = arr["contact_max_correcting_vel"];
        msg->contact_max_correcting_vel = contact_max_correcting_vel_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'contact_max_correcting_vel' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'contact_max_correcting_vel' is wrong type; expected a double.");
    }
    try {
        //cfm
        const matlab::data::TypedArray<double> cfm_arr = arr["cfm"];
        msg->cfm = cfm_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'cfm' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'cfm' is wrong type; expected a double.");
    }
    try {
        //erp
        const matlab::data::TypedArray<double> erp_arr = arr["erp"];
        msg->erp = erp_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'erp' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'erp' is wrong type; expected a double.");
    }
    try {
        //max_contacts
        const matlab::data::TypedArray<uint32_t> max_contacts_arr = arr["max_contacts"];
        msg->max_contacts = max_contacts_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'max_contacts' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'max_contacts' is wrong type; expected a uint32.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_ODEPhysics_common::get_arr(MDFactory_T& factory, const gazebo_msgs::msg::ODEPhysics* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","auto_disable_bodies","sor_pgs_precon_iters","sor_pgs_iters","sor_pgs_w","sor_pgs_rms_error_tol","contact_surface_layer","contact_max_correcting_vel","cfm","erp","max_contacts"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/ODEPhysics");
    // auto_disable_bodies
    auto currentElement_auto_disable_bodies = (msg + ctr)->auto_disable_bodies;
    outArray[ctr]["auto_disable_bodies"] = factory.createScalar(currentElement_auto_disable_bodies);
    // sor_pgs_precon_iters
    auto currentElement_sor_pgs_precon_iters = (msg + ctr)->sor_pgs_precon_iters;
    outArray[ctr]["sor_pgs_precon_iters"] = factory.createScalar(currentElement_sor_pgs_precon_iters);
    // sor_pgs_iters
    auto currentElement_sor_pgs_iters = (msg + ctr)->sor_pgs_iters;
    outArray[ctr]["sor_pgs_iters"] = factory.createScalar(currentElement_sor_pgs_iters);
    // sor_pgs_w
    auto currentElement_sor_pgs_w = (msg + ctr)->sor_pgs_w;
    outArray[ctr]["sor_pgs_w"] = factory.createScalar(currentElement_sor_pgs_w);
    // sor_pgs_rms_error_tol
    auto currentElement_sor_pgs_rms_error_tol = (msg + ctr)->sor_pgs_rms_error_tol;
    outArray[ctr]["sor_pgs_rms_error_tol"] = factory.createScalar(currentElement_sor_pgs_rms_error_tol);
    // contact_surface_layer
    auto currentElement_contact_surface_layer = (msg + ctr)->contact_surface_layer;
    outArray[ctr]["contact_surface_layer"] = factory.createScalar(currentElement_contact_surface_layer);
    // contact_max_correcting_vel
    auto currentElement_contact_max_correcting_vel = (msg + ctr)->contact_max_correcting_vel;
    outArray[ctr]["contact_max_correcting_vel"] = factory.createScalar(currentElement_contact_max_correcting_vel);
    // cfm
    auto currentElement_cfm = (msg + ctr)->cfm;
    outArray[ctr]["cfm"] = factory.createScalar(currentElement_cfm);
    // erp
    auto currentElement_erp = (msg + ctr)->erp;
    outArray[ctr]["erp"] = factory.createScalar(currentElement_erp);
    // max_contacts
    auto currentElement_max_contacts = (msg + ctr)->max_contacts;
    outArray[ctr]["max_contacts"] = factory.createScalar(currentElement_max_contacts);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_ODEPhysics_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_ODEPhysics_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_ODEPhysics_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<gazebo_msgs::msg::ODEPhysics,ros2_gazebo_msgs_msg_ODEPhysics_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_gazebo_msgs_ODEPhysics_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::msg::ODEPhysics,ros2_gazebo_msgs_msg_ODEPhysics_common>>();
  }
  std::shared_ptr<void> ros2_gazebo_msgs_ODEPhysics_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<gazebo_msgs::msg::ODEPhysics>();
    ros2_gazebo_msgs_msg_ODEPhysics_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_gazebo_msgs_ODEPhysics_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_gazebo_msgs_msg_ODEPhysics_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (gazebo_msgs::msg::ODEPhysics*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_ODEPhysics_common, MATLABROS2MsgInterface<gazebo_msgs::msg::ODEPhysics>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_ODEPhysics_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER