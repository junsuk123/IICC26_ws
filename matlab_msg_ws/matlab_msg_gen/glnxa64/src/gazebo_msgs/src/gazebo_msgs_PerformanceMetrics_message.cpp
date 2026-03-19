// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/PerformanceMetrics
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
#include "gazebo_msgs/msg/performance_metrics.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_PerformanceMetrics_common : public MATLABROS2MsgInterface<gazebo_msgs::msg::PerformanceMetrics> {
  public:
    virtual ~ros2_gazebo_msgs_msg_PerformanceMetrics_common(){}
    virtual void copy_from_struct(gazebo_msgs::msg::PerformanceMetrics* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::msg::PerformanceMetrics* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_PerformanceMetrics_common::copy_from_struct(gazebo_msgs::msg::PerformanceMetrics* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //header
        const matlab::data::StructArray header_arr = arr["header"];
        auto msgClassPtr_header = getCommonObject<std_msgs::msg::Header>("ros2_std_msgs_msg_Header_common",loader);
        msgClassPtr_header->copy_from_struct(&msg->header,header_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'header' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'header' is wrong type; expected a struct.");
    }
    try {
        //real_time_factor
        const matlab::data::TypedArray<double> real_time_factor_arr = arr["real_time_factor"];
        msg->real_time_factor = real_time_factor_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'real_time_factor' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'real_time_factor' is wrong type; expected a double.");
    }
    try {
        //sensors
        const matlab::data::StructArray sensors_arr = arr["sensors"];
        for (auto _sensorsarr : sensors_arr) {
        	gazebo_msgs::msg::SensorPerformanceMetric _val;
        auto msgClassPtr_sensors = getCommonObject<gazebo_msgs::msg::SensorPerformanceMetric>("ros2_gazebo_msgs_msg_SensorPerformanceMetric_common",loader);
        msgClassPtr_sensors->copy_from_struct(&_val,_sensorsarr,loader);
        	msg->sensors.push_back(_val);
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'sensors' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'sensors' is wrong type; expected a struct.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_PerformanceMetrics_common::get_arr(MDFactory_T& factory, const gazebo_msgs::msg::PerformanceMetrics* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","header","real_time_factor","sensors"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/PerformanceMetrics");
    // header
    auto currentElement_header = (msg + ctr)->header;
    auto msgClassPtr_header = getCommonObject<std_msgs::msg::Header>("ros2_std_msgs_msg_Header_common",loader);
    outArray[ctr]["header"] = msgClassPtr_header->get_arr(factory, &currentElement_header, loader);
    // real_time_factor
    auto currentElement_real_time_factor = (msg + ctr)->real_time_factor;
    outArray[ctr]["real_time_factor"] = factory.createScalar(currentElement_real_time_factor);
    // sensors
    auto currentElement_sensors = (msg + ctr)->sensors;
    auto msgClassPtr_sensors = getCommonObject<gazebo_msgs::msg::SensorPerformanceMetric>("ros2_gazebo_msgs_msg_SensorPerformanceMetric_common",loader);
    outArray[ctr]["sensors"] = msgClassPtr_sensors->get_arr(factory,&currentElement_sensors[0],loader,currentElement_sensors.size());
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_PerformanceMetrics_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_PerformanceMetrics_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_PerformanceMetrics_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<gazebo_msgs::msg::PerformanceMetrics,ros2_gazebo_msgs_msg_PerformanceMetrics_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_gazebo_msgs_PerformanceMetrics_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::msg::PerformanceMetrics,ros2_gazebo_msgs_msg_PerformanceMetrics_common>>();
  }
  std::shared_ptr<void> ros2_gazebo_msgs_PerformanceMetrics_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<gazebo_msgs::msg::PerformanceMetrics>();
    ros2_gazebo_msgs_msg_PerformanceMetrics_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_gazebo_msgs_PerformanceMetrics_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_gazebo_msgs_msg_PerformanceMetrics_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (gazebo_msgs::msg::PerformanceMetrics*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_PerformanceMetrics_common, MATLABROS2MsgInterface<gazebo_msgs::msg::PerformanceMetrics>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_PerformanceMetrics_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER