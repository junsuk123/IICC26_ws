// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for geometry_msgs/Quaternion
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
#include "geometry_msgs/msg/quaternion.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GEOMETRY_MSGS_EXPORT ros2_geometry_msgs_msg_Quaternion_common : public MATLABROS2MsgInterface<geometry_msgs::msg::Quaternion> {
  public:
    virtual ~ros2_geometry_msgs_msg_Quaternion_common(){}
    virtual void copy_from_struct(geometry_msgs::msg::Quaternion* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const geometry_msgs::msg::Quaternion* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_geometry_msgs_msg_Quaternion_common::copy_from_struct(geometry_msgs::msg::Quaternion* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //x
        const matlab::data::TypedArray<double> x_arr = arr["x"];
        msg->x = x_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'x' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'x' is wrong type; expected a double.");
    }
    try {
        //y
        const matlab::data::TypedArray<double> y_arr = arr["y"];
        msg->y = y_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'y' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'y' is wrong type; expected a double.");
    }
    try {
        //z
        const matlab::data::TypedArray<double> z_arr = arr["z"];
        msg->z = z_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'z' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'z' is wrong type; expected a double.");
    }
    try {
        //w
        const matlab::data::TypedArray<double> w_arr = arr["w"];
        msg->w = w_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'w' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'w' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_geometry_msgs_msg_Quaternion_common::get_arr(MDFactory_T& factory, const geometry_msgs::msg::Quaternion* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","x","y","z","w"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("geometry_msgs/Quaternion");
    // x
    auto currentElement_x = (msg + ctr)->x;
    outArray[ctr]["x"] = factory.createScalar(currentElement_x);
    // y
    auto currentElement_y = (msg + ctr)->y;
    outArray[ctr]["y"] = factory.createScalar(currentElement_y);
    // z
    auto currentElement_z = (msg + ctr)->z;
    outArray[ctr]["z"] = factory.createScalar(currentElement_z);
    // w
    auto currentElement_w = (msg + ctr)->w;
    outArray[ctr]["w"] = factory.createScalar(currentElement_w);
    }
    return std::move(outArray);
  } 
class GEOMETRY_MSGS_EXPORT ros2_geometry_msgs_Quaternion_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_geometry_msgs_Quaternion_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_geometry_msgs_Quaternion_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<geometry_msgs::msg::Quaternion,ros2_geometry_msgs_msg_Quaternion_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_geometry_msgs_Quaternion_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<geometry_msgs::msg::Quaternion,ros2_geometry_msgs_msg_Quaternion_common>>();
  }
  std::shared_ptr<void> ros2_geometry_msgs_Quaternion_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<geometry_msgs::msg::Quaternion>();
    ros2_geometry_msgs_msg_Quaternion_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_geometry_msgs_Quaternion_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_geometry_msgs_msg_Quaternion_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (geometry_msgs::msg::Quaternion*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_geometry_msgs_msg_Quaternion_common, MATLABROS2MsgInterface<geometry_msgs::msg::Quaternion>)
CLASS_LOADER_REGISTER_CLASS(ros2_geometry_msgs_Quaternion_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER