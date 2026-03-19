// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/ODEJointProperties
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
#include "gazebo_msgs/msg/ode_joint_properties.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_ODEJointProperties_common : public MATLABROS2MsgInterface<gazebo_msgs::msg::ODEJointProperties> {
  public:
    virtual ~ros2_gazebo_msgs_msg_ODEJointProperties_common(){}
    virtual void copy_from_struct(gazebo_msgs::msg::ODEJointProperties* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::msg::ODEJointProperties* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_ODEJointProperties_common::copy_from_struct(gazebo_msgs::msg::ODEJointProperties* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
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
        //hi_stop
        const matlab::data::TypedArray<double> hi_stop_arr = arr["hi_stop"];
        size_t nelem = hi_stop_arr.getNumberOfElements();
        	msg->hi_stop.resize(nelem);
        	std::copy(hi_stop_arr.begin(), hi_stop_arr.begin()+nelem, msg->hi_stop.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'hi_stop' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'hi_stop' is wrong type; expected a double.");
    }
    try {
        //lo_stop
        const matlab::data::TypedArray<double> lo_stop_arr = arr["lo_stop"];
        size_t nelem = lo_stop_arr.getNumberOfElements();
        	msg->lo_stop.resize(nelem);
        	std::copy(lo_stop_arr.begin(), lo_stop_arr.begin()+nelem, msg->lo_stop.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'lo_stop' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'lo_stop' is wrong type; expected a double.");
    }
    try {
        //erp
        const matlab::data::TypedArray<double> erp_arr = arr["erp"];
        size_t nelem = erp_arr.getNumberOfElements();
        	msg->erp.resize(nelem);
        	std::copy(erp_arr.begin(), erp_arr.begin()+nelem, msg->erp.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'erp' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'erp' is wrong type; expected a double.");
    }
    try {
        //cfm
        const matlab::data::TypedArray<double> cfm_arr = arr["cfm"];
        size_t nelem = cfm_arr.getNumberOfElements();
        	msg->cfm.resize(nelem);
        	std::copy(cfm_arr.begin(), cfm_arr.begin()+nelem, msg->cfm.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'cfm' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'cfm' is wrong type; expected a double.");
    }
    try {
        //stop_erp
        const matlab::data::TypedArray<double> stop_erp_arr = arr["stop_erp"];
        size_t nelem = stop_erp_arr.getNumberOfElements();
        	msg->stop_erp.resize(nelem);
        	std::copy(stop_erp_arr.begin(), stop_erp_arr.begin()+nelem, msg->stop_erp.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'stop_erp' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'stop_erp' is wrong type; expected a double.");
    }
    try {
        //stop_cfm
        const matlab::data::TypedArray<double> stop_cfm_arr = arr["stop_cfm"];
        size_t nelem = stop_cfm_arr.getNumberOfElements();
        	msg->stop_cfm.resize(nelem);
        	std::copy(stop_cfm_arr.begin(), stop_cfm_arr.begin()+nelem, msg->stop_cfm.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'stop_cfm' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'stop_cfm' is wrong type; expected a double.");
    }
    try {
        //fudge_factor
        const matlab::data::TypedArray<double> fudge_factor_arr = arr["fudge_factor"];
        size_t nelem = fudge_factor_arr.getNumberOfElements();
        	msg->fudge_factor.resize(nelem);
        	std::copy(fudge_factor_arr.begin(), fudge_factor_arr.begin()+nelem, msg->fudge_factor.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'fudge_factor' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'fudge_factor' is wrong type; expected a double.");
    }
    try {
        //fmax
        const matlab::data::TypedArray<double> fmax_arr = arr["fmax"];
        size_t nelem = fmax_arr.getNumberOfElements();
        	msg->fmax.resize(nelem);
        	std::copy(fmax_arr.begin(), fmax_arr.begin()+nelem, msg->fmax.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'fmax' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'fmax' is wrong type; expected a double.");
    }
    try {
        //vel
        const matlab::data::TypedArray<double> vel_arr = arr["vel"];
        size_t nelem = vel_arr.getNumberOfElements();
        	msg->vel.resize(nelem);
        	std::copy(vel_arr.begin(), vel_arr.begin()+nelem, msg->vel.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'vel' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'vel' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_ODEJointProperties_common::get_arr(MDFactory_T& factory, const gazebo_msgs::msg::ODEJointProperties* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","damping","hi_stop","lo_stop","erp","cfm","stop_erp","stop_cfm","fudge_factor","fmax","vel"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/ODEJointProperties");
    // damping
    auto currentElement_damping = (msg + ctr)->damping;
    outArray[ctr]["damping"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_damping_type::const_iterator, double>({currentElement_damping.size(), 1}, currentElement_damping.begin(), currentElement_damping.end());
    // hi_stop
    auto currentElement_hi_stop = (msg + ctr)->hi_stop;
    outArray[ctr]["hi_stop"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_hi_stop_type::const_iterator, double>({currentElement_hi_stop.size(), 1}, currentElement_hi_stop.begin(), currentElement_hi_stop.end());
    // lo_stop
    auto currentElement_lo_stop = (msg + ctr)->lo_stop;
    outArray[ctr]["lo_stop"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_lo_stop_type::const_iterator, double>({currentElement_lo_stop.size(), 1}, currentElement_lo_stop.begin(), currentElement_lo_stop.end());
    // erp
    auto currentElement_erp = (msg + ctr)->erp;
    outArray[ctr]["erp"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_erp_type::const_iterator, double>({currentElement_erp.size(), 1}, currentElement_erp.begin(), currentElement_erp.end());
    // cfm
    auto currentElement_cfm = (msg + ctr)->cfm;
    outArray[ctr]["cfm"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_cfm_type::const_iterator, double>({currentElement_cfm.size(), 1}, currentElement_cfm.begin(), currentElement_cfm.end());
    // stop_erp
    auto currentElement_stop_erp = (msg + ctr)->stop_erp;
    outArray[ctr]["stop_erp"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_stop_erp_type::const_iterator, double>({currentElement_stop_erp.size(), 1}, currentElement_stop_erp.begin(), currentElement_stop_erp.end());
    // stop_cfm
    auto currentElement_stop_cfm = (msg + ctr)->stop_cfm;
    outArray[ctr]["stop_cfm"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_stop_cfm_type::const_iterator, double>({currentElement_stop_cfm.size(), 1}, currentElement_stop_cfm.begin(), currentElement_stop_cfm.end());
    // fudge_factor
    auto currentElement_fudge_factor = (msg + ctr)->fudge_factor;
    outArray[ctr]["fudge_factor"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_fudge_factor_type::const_iterator, double>({currentElement_fudge_factor.size(), 1}, currentElement_fudge_factor.begin(), currentElement_fudge_factor.end());
    // fmax
    auto currentElement_fmax = (msg + ctr)->fmax;
    outArray[ctr]["fmax"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_fmax_type::const_iterator, double>({currentElement_fmax.size(), 1}, currentElement_fmax.begin(), currentElement_fmax.end());
    // vel
    auto currentElement_vel = (msg + ctr)->vel;
    outArray[ctr]["vel"] = factory.createArray<gazebo_msgs::msg::ODEJointProperties::_vel_type::const_iterator, double>({currentElement_vel.size(), 1}, currentElement_vel.begin(), currentElement_vel.end());
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_ODEJointProperties_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_ODEJointProperties_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_ODEJointProperties_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<gazebo_msgs::msg::ODEJointProperties,ros2_gazebo_msgs_msg_ODEJointProperties_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_gazebo_msgs_ODEJointProperties_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::msg::ODEJointProperties,ros2_gazebo_msgs_msg_ODEJointProperties_common>>();
  }
  std::shared_ptr<void> ros2_gazebo_msgs_ODEJointProperties_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<gazebo_msgs::msg::ODEJointProperties>();
    ros2_gazebo_msgs_msg_ODEJointProperties_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_gazebo_msgs_ODEJointProperties_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_gazebo_msgs_msg_ODEJointProperties_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (gazebo_msgs::msg::ODEJointProperties*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_ODEJointProperties_common, MATLABROS2MsgInterface<gazebo_msgs::msg::ODEJointProperties>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_ODEJointProperties_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER