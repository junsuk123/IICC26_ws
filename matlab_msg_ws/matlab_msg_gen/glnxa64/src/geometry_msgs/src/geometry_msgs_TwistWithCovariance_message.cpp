// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for geometry_msgs/TwistWithCovariance
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
#include "geometry_msgs/msg/twist_with_covariance.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GEOMETRY_MSGS_EXPORT ros2_geometry_msgs_msg_TwistWithCovariance_common : public MATLABROS2MsgInterface<geometry_msgs::msg::TwistWithCovariance> {
  public:
    virtual ~ros2_geometry_msgs_msg_TwistWithCovariance_common(){}
    virtual void copy_from_struct(geometry_msgs::msg::TwistWithCovariance* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const geometry_msgs::msg::TwistWithCovariance* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_geometry_msgs_msg_TwistWithCovariance_common::copy_from_struct(geometry_msgs::msg::TwistWithCovariance* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //twist
        const matlab::data::StructArray twist_arr = arr["twist"];
        auto msgClassPtr_twist = getCommonObject<geometry_msgs::msg::Twist>("ros2_geometry_msgs_msg_Twist_common",loader);
        msgClassPtr_twist->copy_from_struct(&msg->twist,twist_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'twist' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'twist' is wrong type; expected a struct.");
    }
    try {
        //covariance
        const matlab::data::TypedArray<double> covariance_arr = arr["covariance"];
        size_t nelem = 36;
        	std::copy(covariance_arr.begin(), covariance_arr.begin()+nelem, msg->covariance.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'covariance' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'covariance' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_geometry_msgs_msg_TwistWithCovariance_common::get_arr(MDFactory_T& factory, const geometry_msgs::msg::TwistWithCovariance* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","twist","covariance"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("geometry_msgs/TwistWithCovariance");
    // twist
    auto currentElement_twist = (msg + ctr)->twist;
    auto msgClassPtr_twist = getCommonObject<geometry_msgs::msg::Twist>("ros2_geometry_msgs_msg_Twist_common",loader);
    outArray[ctr]["twist"] = msgClassPtr_twist->get_arr(factory, &currentElement_twist, loader);
    // covariance
    auto currentElement_covariance = (msg + ctr)->covariance;
    outArray[ctr]["covariance"] = factory.createArray<geometry_msgs::msg::TwistWithCovariance::_covariance_type::const_iterator, double>({currentElement_covariance.size(), 1}, currentElement_covariance.begin(), currentElement_covariance.end());
    }
    return std::move(outArray);
  } 
class GEOMETRY_MSGS_EXPORT ros2_geometry_msgs_TwistWithCovariance_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_geometry_msgs_TwistWithCovariance_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_geometry_msgs_TwistWithCovariance_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<geometry_msgs::msg::TwistWithCovariance,ros2_geometry_msgs_msg_TwistWithCovariance_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_geometry_msgs_TwistWithCovariance_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<geometry_msgs::msg::TwistWithCovariance,ros2_geometry_msgs_msg_TwistWithCovariance_common>>();
  }
  std::shared_ptr<void> ros2_geometry_msgs_TwistWithCovariance_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<geometry_msgs::msg::TwistWithCovariance>();
    ros2_geometry_msgs_msg_TwistWithCovariance_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_geometry_msgs_TwistWithCovariance_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_geometry_msgs_msg_TwistWithCovariance_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (geometry_msgs::msg::TwistWithCovariance*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_geometry_msgs_msg_TwistWithCovariance_common, MATLABROS2MsgInterface<geometry_msgs::msg::TwistWithCovariance>)
CLASS_LOADER_REGISTER_CLASS(ros2_geometry_msgs_TwistWithCovariance_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER