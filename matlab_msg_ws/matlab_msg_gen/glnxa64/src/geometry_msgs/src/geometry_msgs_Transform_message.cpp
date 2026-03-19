// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for geometry_msgs/Transform
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
#include "geometry_msgs/msg/transform.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GEOMETRY_MSGS_EXPORT ros2_geometry_msgs_msg_Transform_common : public MATLABROS2MsgInterface<geometry_msgs::msg::Transform> {
  public:
    virtual ~ros2_geometry_msgs_msg_Transform_common(){}
    virtual void copy_from_struct(geometry_msgs::msg::Transform* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const geometry_msgs::msg::Transform* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_geometry_msgs_msg_Transform_common::copy_from_struct(geometry_msgs::msg::Transform* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //translation
        const matlab::data::StructArray translation_arr = arr["translation"];
        auto msgClassPtr_translation = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
        msgClassPtr_translation->copy_from_struct(&msg->translation,translation_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'translation' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'translation' is wrong type; expected a struct.");
    }
    try {
        //rotation
        const matlab::data::StructArray rotation_arr = arr["rotation"];
        auto msgClassPtr_rotation = getCommonObject<geometry_msgs::msg::Quaternion>("ros2_geometry_msgs_msg_Quaternion_common",loader);
        msgClassPtr_rotation->copy_from_struct(&msg->rotation,rotation_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'rotation' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'rotation' is wrong type; expected a struct.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_geometry_msgs_msg_Transform_common::get_arr(MDFactory_T& factory, const geometry_msgs::msg::Transform* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","translation","rotation"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("geometry_msgs/Transform");
    // translation
    auto currentElement_translation = (msg + ctr)->translation;
    auto msgClassPtr_translation = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
    outArray[ctr]["translation"] = msgClassPtr_translation->get_arr(factory, &currentElement_translation, loader);
    // rotation
    auto currentElement_rotation = (msg + ctr)->rotation;
    auto msgClassPtr_rotation = getCommonObject<geometry_msgs::msg::Quaternion>("ros2_geometry_msgs_msg_Quaternion_common",loader);
    outArray[ctr]["rotation"] = msgClassPtr_rotation->get_arr(factory, &currentElement_rotation, loader);
    }
    return std::move(outArray);
  } 
class GEOMETRY_MSGS_EXPORT ros2_geometry_msgs_Transform_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_geometry_msgs_Transform_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_geometry_msgs_Transform_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<geometry_msgs::msg::Transform,ros2_geometry_msgs_msg_Transform_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_geometry_msgs_Transform_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<geometry_msgs::msg::Transform,ros2_geometry_msgs_msg_Transform_common>>();
  }
  std::shared_ptr<void> ros2_geometry_msgs_Transform_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<geometry_msgs::msg::Transform>();
    ros2_geometry_msgs_msg_Transform_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_geometry_msgs_Transform_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_geometry_msgs_msg_Transform_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (geometry_msgs::msg::Transform*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_geometry_msgs_msg_Transform_common, MATLABROS2MsgInterface<geometry_msgs::msg::Transform>)
CLASS_LOADER_REGISTER_CLASS(ros2_geometry_msgs_Transform_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER