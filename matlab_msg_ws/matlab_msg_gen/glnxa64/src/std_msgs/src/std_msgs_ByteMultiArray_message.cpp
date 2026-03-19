// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for std_msgs/ByteMultiArray
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
#include "std_msgs/msg/byte_multi_array.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class STD_MSGS_EXPORT ros2_std_msgs_msg_ByteMultiArray_common : public MATLABROS2MsgInterface<std_msgs::msg::ByteMultiArray> {
  public:
    virtual ~ros2_std_msgs_msg_ByteMultiArray_common(){}
    virtual void copy_from_struct(std_msgs::msg::ByteMultiArray* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const std_msgs::msg::ByteMultiArray* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_std_msgs_msg_ByteMultiArray_common::copy_from_struct(std_msgs::msg::ByteMultiArray* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //layout
        const matlab::data::StructArray layout_arr = arr["layout"];
        auto msgClassPtr_layout = getCommonObject<std_msgs::msg::MultiArrayLayout>("ros2_std_msgs_msg_MultiArrayLayout_common",loader);
        msgClassPtr_layout->copy_from_struct(&msg->layout,layout_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'layout' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'layout' is wrong type; expected a struct.");
    }
    try {
        //data
        const matlab::data::TypedArray<uint8_t> data_arr = arr["data"];
        size_t nelem = data_arr.getNumberOfElements();
        	msg->data.resize(nelem);
        	std::copy(data_arr.begin(), data_arr.begin()+nelem, msg->data.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'data' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'data' is wrong type; expected a uint8.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_std_msgs_msg_ByteMultiArray_common::get_arr(MDFactory_T& factory, const std_msgs::msg::ByteMultiArray* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","layout","data"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("std_msgs/ByteMultiArray");
    // layout
    auto currentElement_layout = (msg + ctr)->layout;
    auto msgClassPtr_layout = getCommonObject<std_msgs::msg::MultiArrayLayout>("ros2_std_msgs_msg_MultiArrayLayout_common",loader);
    outArray[ctr]["layout"] = msgClassPtr_layout->get_arr(factory, &currentElement_layout, loader);
    // data
    auto currentElement_data = (msg + ctr)->data;
    outArray[ctr]["data"] = factory.createArray<std_msgs::msg::ByteMultiArray::_data_type::const_iterator, uint8_t>({currentElement_data.size(), 1}, currentElement_data.begin(), currentElement_data.end());
    }
    return std::move(outArray);
  } 
class STD_MSGS_EXPORT ros2_std_msgs_ByteMultiArray_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_std_msgs_ByteMultiArray_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_std_msgs_ByteMultiArray_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<std_msgs::msg::ByteMultiArray,ros2_std_msgs_msg_ByteMultiArray_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_std_msgs_ByteMultiArray_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<std_msgs::msg::ByteMultiArray,ros2_std_msgs_msg_ByteMultiArray_common>>();
  }
  std::shared_ptr<void> ros2_std_msgs_ByteMultiArray_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<std_msgs::msg::ByteMultiArray>();
    ros2_std_msgs_msg_ByteMultiArray_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_std_msgs_ByteMultiArray_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_std_msgs_msg_ByteMultiArray_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (std_msgs::msg::ByteMultiArray*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_std_msgs_msg_ByteMultiArray_common, MATLABROS2MsgInterface<std_msgs::msg::ByteMultiArray>)
CLASS_LOADER_REGISTER_CLASS(ros2_std_msgs_ByteMultiArray_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER