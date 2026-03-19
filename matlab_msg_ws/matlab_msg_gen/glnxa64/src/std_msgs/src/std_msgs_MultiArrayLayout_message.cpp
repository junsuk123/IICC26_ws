// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for std_msgs/MultiArrayLayout
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
#include "std_msgs/msg/multi_array_layout.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class STD_MSGS_EXPORT ros2_std_msgs_msg_MultiArrayLayout_common : public MATLABROS2MsgInterface<std_msgs::msg::MultiArrayLayout> {
  public:
    virtual ~ros2_std_msgs_msg_MultiArrayLayout_common(){}
    virtual void copy_from_struct(std_msgs::msg::MultiArrayLayout* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const std_msgs::msg::MultiArrayLayout* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_std_msgs_msg_MultiArrayLayout_common::copy_from_struct(std_msgs::msg::MultiArrayLayout* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //dim
        const matlab::data::StructArray dim_arr = arr["dim"];
        for (auto _dimarr : dim_arr) {
        	std_msgs::msg::MultiArrayDimension _val;
        auto msgClassPtr_dim = getCommonObject<std_msgs::msg::MultiArrayDimension>("ros2_std_msgs_msg_MultiArrayDimension_common",loader);
        msgClassPtr_dim->copy_from_struct(&_val,_dimarr,loader);
        	msg->dim.push_back(_val);
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'dim' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'dim' is wrong type; expected a struct.");
    }
    try {
        //data_offset
        const matlab::data::TypedArray<uint32_t> data_offset_arr = arr["data_offset"];
        msg->data_offset = data_offset_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'data_offset' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'data_offset' is wrong type; expected a uint32.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_std_msgs_msg_MultiArrayLayout_common::get_arr(MDFactory_T& factory, const std_msgs::msg::MultiArrayLayout* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","dim","data_offset"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("std_msgs/MultiArrayLayout");
    // dim
    auto currentElement_dim = (msg + ctr)->dim;
    auto msgClassPtr_dim = getCommonObject<std_msgs::msg::MultiArrayDimension>("ros2_std_msgs_msg_MultiArrayDimension_common",loader);
    outArray[ctr]["dim"] = msgClassPtr_dim->get_arr(factory,&currentElement_dim[0],loader,currentElement_dim.size());
    // data_offset
    auto currentElement_data_offset = (msg + ctr)->data_offset;
    outArray[ctr]["data_offset"] = factory.createScalar(currentElement_data_offset);
    }
    return std::move(outArray);
  } 
class STD_MSGS_EXPORT ros2_std_msgs_MultiArrayLayout_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_std_msgs_MultiArrayLayout_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_std_msgs_MultiArrayLayout_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<std_msgs::msg::MultiArrayLayout,ros2_std_msgs_msg_MultiArrayLayout_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_std_msgs_MultiArrayLayout_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<std_msgs::msg::MultiArrayLayout,ros2_std_msgs_msg_MultiArrayLayout_common>>();
  }
  std::shared_ptr<void> ros2_std_msgs_MultiArrayLayout_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<std_msgs::msg::MultiArrayLayout>();
    ros2_std_msgs_msg_MultiArrayLayout_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_std_msgs_MultiArrayLayout_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_std_msgs_msg_MultiArrayLayout_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (std_msgs::msg::MultiArrayLayout*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_std_msgs_msg_MultiArrayLayout_common, MATLABROS2MsgInterface<std_msgs::msg::MultiArrayLayout>)
CLASS_LOADER_REGISTER_CLASS(ros2_std_msgs_MultiArrayLayout_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER