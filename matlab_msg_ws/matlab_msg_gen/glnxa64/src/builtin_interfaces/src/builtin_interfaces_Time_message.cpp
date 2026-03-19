// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for builtin_interfaces/Time
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
#include "builtin_interfaces/msg/time.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class BUILTIN_INTERFACES_EXPORT ros2_builtin_interfaces_msg_Time_common : public MATLABROS2MsgInterface<builtin_interfaces::msg::Time> {
  public:
    virtual ~ros2_builtin_interfaces_msg_Time_common(){}
    virtual void copy_from_struct(builtin_interfaces::msg::Time* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const builtin_interfaces::msg::Time* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_builtin_interfaces_msg_Time_common::copy_from_struct(builtin_interfaces::msg::Time* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //sec
        const matlab::data::TypedArray<int32_t> sec_arr = arr["sec"];
        msg->sec = sec_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'sec' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'sec' is wrong type; expected a int32.");
    }
    try {
        //nanosec
        const matlab::data::TypedArray<uint32_t> nanosec_arr = arr["nanosec"];
        msg->nanosec = nanosec_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'nanosec' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'nanosec' is wrong type; expected a uint32.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_builtin_interfaces_msg_Time_common::get_arr(MDFactory_T& factory, const builtin_interfaces::msg::Time* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","sec","nanosec"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("builtin_interfaces/Time");
    // sec
    auto currentElement_sec = (msg + ctr)->sec;
    outArray[ctr]["sec"] = factory.createScalar(currentElement_sec);
    // nanosec
    auto currentElement_nanosec = (msg + ctr)->nanosec;
    outArray[ctr]["nanosec"] = factory.createScalar(currentElement_nanosec);
    }
    return std::move(outArray);
  } 
class BUILTIN_INTERFACES_EXPORT ros2_builtin_interfaces_Time_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_builtin_interfaces_Time_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_builtin_interfaces_Time_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<builtin_interfaces::msg::Time,ros2_builtin_interfaces_msg_Time_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_builtin_interfaces_Time_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<builtin_interfaces::msg::Time,ros2_builtin_interfaces_msg_Time_common>>();
  }
  std::shared_ptr<void> ros2_builtin_interfaces_Time_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<builtin_interfaces::msg::Time>();
    ros2_builtin_interfaces_msg_Time_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_builtin_interfaces_Time_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_builtin_interfaces_msg_Time_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (builtin_interfaces::msg::Time*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_builtin_interfaces_msg_Time_common, MATLABROS2MsgInterface<builtin_interfaces::msg::Time>)
CLASS_LOADER_REGISTER_CLASS(ros2_builtin_interfaces_Time_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER