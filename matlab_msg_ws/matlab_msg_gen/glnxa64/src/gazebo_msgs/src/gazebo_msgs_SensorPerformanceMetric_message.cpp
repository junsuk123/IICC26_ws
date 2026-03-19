// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/SensorPerformanceMetric
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
#include "gazebo_msgs/msg/sensor_performance_metric.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_SensorPerformanceMetric_common : public MATLABROS2MsgInterface<gazebo_msgs::msg::SensorPerformanceMetric> {
  public:
    virtual ~ros2_gazebo_msgs_msg_SensorPerformanceMetric_common(){}
    virtual void copy_from_struct(gazebo_msgs::msg::SensorPerformanceMetric* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::msg::SensorPerformanceMetric* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_SensorPerformanceMetric_common::copy_from_struct(gazebo_msgs::msg::SensorPerformanceMetric* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //name
        const matlab::data::CharArray name_arr = arr["name"];
        msg->name = name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'name' is wrong type; expected a string.");
    }
    try {
        //sim_update_rate
        const matlab::data::TypedArray<double> sim_update_rate_arr = arr["sim_update_rate"];
        msg->sim_update_rate = sim_update_rate_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'sim_update_rate' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'sim_update_rate' is wrong type; expected a double.");
    }
    try {
        //real_update_rate
        const matlab::data::TypedArray<double> real_update_rate_arr = arr["real_update_rate"];
        msg->real_update_rate = real_update_rate_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'real_update_rate' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'real_update_rate' is wrong type; expected a double.");
    }
    try {
        //fps
        const matlab::data::TypedArray<double> fps_arr = arr["fps"];
        msg->fps = fps_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'fps' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'fps' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_SensorPerformanceMetric_common::get_arr(MDFactory_T& factory, const gazebo_msgs::msg::SensorPerformanceMetric* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","name","sim_update_rate","real_update_rate","fps"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/SensorPerformanceMetric");
    // name
    auto currentElement_name = (msg + ctr)->name;
    outArray[ctr]["name"] = factory.createCharArray(currentElement_name);
    // sim_update_rate
    auto currentElement_sim_update_rate = (msg + ctr)->sim_update_rate;
    outArray[ctr]["sim_update_rate"] = factory.createScalar(currentElement_sim_update_rate);
    // real_update_rate
    auto currentElement_real_update_rate = (msg + ctr)->real_update_rate;
    outArray[ctr]["real_update_rate"] = factory.createScalar(currentElement_real_update_rate);
    // fps
    auto currentElement_fps = (msg + ctr)->fps;
    outArray[ctr]["fps"] = factory.createScalar(currentElement_fps);
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_SensorPerformanceMetric_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_SensorPerformanceMetric_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_SensorPerformanceMetric_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<gazebo_msgs::msg::SensorPerformanceMetric,ros2_gazebo_msgs_msg_SensorPerformanceMetric_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_gazebo_msgs_SensorPerformanceMetric_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::msg::SensorPerformanceMetric,ros2_gazebo_msgs_msg_SensorPerformanceMetric_common>>();
  }
  std::shared_ptr<void> ros2_gazebo_msgs_SensorPerformanceMetric_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<gazebo_msgs::msg::SensorPerformanceMetric>();
    ros2_gazebo_msgs_msg_SensorPerformanceMetric_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_gazebo_msgs_SensorPerformanceMetric_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_gazebo_msgs_msg_SensorPerformanceMetric_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (gazebo_msgs::msg::SensorPerformanceMetric*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_SensorPerformanceMetric_common, MATLABROS2MsgInterface<gazebo_msgs::msg::SensorPerformanceMetric>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_SensorPerformanceMetric_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER