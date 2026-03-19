// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for std_msgs/MultiArrayDimension
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
#include "std_msgs/msg/multi_array_dimension.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class STD_MSGS_EXPORT ros2_std_msgs_msg_MultiArrayDimension_common : public MATLABROS2MsgInterface<std_msgs::msg::MultiArrayDimension> {
  public:
    virtual ~ros2_std_msgs_msg_MultiArrayDimension_common(){}
    virtual void copy_from_struct(std_msgs::msg::MultiArrayDimension* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const std_msgs::msg::MultiArrayDimension* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_std_msgs_msg_MultiArrayDimension_common::copy_from_struct(std_msgs::msg::MultiArrayDimension* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //label
        const matlab::data::CharArray label_arr = arr["label"];
        msg->label = label_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'label' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'label' is wrong type; expected a string.");
    }
    try {
        //size
        const matlab::data::TypedArray<uint32_t> size_arr = arr["size"];
        msg->size = size_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'size' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'size' is wrong type; expected a uint32.");
    }
    try {
        //stride
        const matlab::data::TypedArray<uint32_t> stride_arr = arr["stride"];
        msg->stride = stride_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'stride' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'stride' is wrong type; expected a uint32.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_std_msgs_msg_MultiArrayDimension_common::get_arr(MDFactory_T& factory, const std_msgs::msg::MultiArrayDimension* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","label","size","stride"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("std_msgs/MultiArrayDimension");
    // label
    auto currentElement_label = (msg + ctr)->label;
    outArray[ctr]["label"] = factory.createCharArray(currentElement_label);
    // size
    auto currentElement_size = (msg + ctr)->size;
    outArray[ctr]["size"] = factory.createScalar(currentElement_size);
    // stride
    auto currentElement_stride = (msg + ctr)->stride;
    outArray[ctr]["stride"] = factory.createScalar(currentElement_stride);
    }
    return std::move(outArray);
  } 
class STD_MSGS_EXPORT ros2_std_msgs_MultiArrayDimension_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_std_msgs_MultiArrayDimension_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_std_msgs_MultiArrayDimension_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<std_msgs::msg::MultiArrayDimension,ros2_std_msgs_msg_MultiArrayDimension_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_std_msgs_MultiArrayDimension_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<std_msgs::msg::MultiArrayDimension,ros2_std_msgs_msg_MultiArrayDimension_common>>();
  }
  std::shared_ptr<void> ros2_std_msgs_MultiArrayDimension_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<std_msgs::msg::MultiArrayDimension>();
    ros2_std_msgs_msg_MultiArrayDimension_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_std_msgs_MultiArrayDimension_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_std_msgs_msg_MultiArrayDimension_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (std_msgs::msg::MultiArrayDimension*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_std_msgs_msg_MultiArrayDimension_common, MATLABROS2MsgInterface<std_msgs::msg::MultiArrayDimension>)
CLASS_LOADER_REGISTER_CLASS(ros2_std_msgs_MultiArrayDimension_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER