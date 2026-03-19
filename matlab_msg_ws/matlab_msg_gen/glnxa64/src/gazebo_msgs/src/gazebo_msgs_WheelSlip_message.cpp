// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/WheelSlip
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
#include "gazebo_msgs/msg/wheel_slip.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_WheelSlip_common : public MATLABROS2MsgInterface<gazebo_msgs::msg::WheelSlip> {
  public:
    virtual ~ros2_gazebo_msgs_msg_WheelSlip_common(){}
    virtual void copy_from_struct(gazebo_msgs::msg::WheelSlip* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::msg::WheelSlip* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_WheelSlip_common::copy_from_struct(gazebo_msgs::msg::WheelSlip* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //name
        const matlab::data::CellArray name_cellarr = arr["name"];
        size_t nelem = name_cellarr.getNumberOfElements();
        for (size_t idx=0; idx < nelem; ++idx){
        	const matlab::data::CharArray name_arr = name_cellarr[idx];
        	msg->name.push_back(name_arr.toAscii());
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'name' is wrong type; expected a string.");
    }
    try {
        //lateral_slip
        const matlab::data::TypedArray<double> lateral_slip_arr = arr["lateral_slip"];
        size_t nelem = lateral_slip_arr.getNumberOfElements();
        	msg->lateral_slip.resize(nelem);
        	std::copy(lateral_slip_arr.begin(), lateral_slip_arr.begin()+nelem, msg->lateral_slip.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'lateral_slip' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'lateral_slip' is wrong type; expected a double.");
    }
    try {
        //longitudinal_slip
        const matlab::data::TypedArray<double> longitudinal_slip_arr = arr["longitudinal_slip"];
        size_t nelem = longitudinal_slip_arr.getNumberOfElements();
        	msg->longitudinal_slip.resize(nelem);
        	std::copy(longitudinal_slip_arr.begin(), longitudinal_slip_arr.begin()+nelem, msg->longitudinal_slip.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'longitudinal_slip' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'longitudinal_slip' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_WheelSlip_common::get_arr(MDFactory_T& factory, const gazebo_msgs::msg::WheelSlip* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","name","lateral_slip","longitudinal_slip"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/WheelSlip");
    // name
    auto currentElement_name = (msg + ctr)->name;
    auto nameoutCell = factory.createCellArray({currentElement_name.size(),1});
    for(size_t idxin = 0; idxin < currentElement_name.size(); ++ idxin){
    	nameoutCell[idxin] = factory.createCharArray(currentElement_name[idxin]);
    }
    outArray[ctr]["name"] = nameoutCell;
    // lateral_slip
    auto currentElement_lateral_slip = (msg + ctr)->lateral_slip;
    outArray[ctr]["lateral_slip"] = factory.createArray<gazebo_msgs::msg::WheelSlip::_lateral_slip_type::const_iterator, double>({currentElement_lateral_slip.size(), 1}, currentElement_lateral_slip.begin(), currentElement_lateral_slip.end());
    // longitudinal_slip
    auto currentElement_longitudinal_slip = (msg + ctr)->longitudinal_slip;
    outArray[ctr]["longitudinal_slip"] = factory.createArray<gazebo_msgs::msg::WheelSlip::_longitudinal_slip_type::const_iterator, double>({currentElement_longitudinal_slip.size(), 1}, currentElement_longitudinal_slip.begin(), currentElement_longitudinal_slip.end());
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_WheelSlip_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_WheelSlip_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_WheelSlip_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<gazebo_msgs::msg::WheelSlip,ros2_gazebo_msgs_msg_WheelSlip_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_gazebo_msgs_WheelSlip_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::msg::WheelSlip,ros2_gazebo_msgs_msg_WheelSlip_common>>();
  }
  std::shared_ptr<void> ros2_gazebo_msgs_WheelSlip_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<gazebo_msgs::msg::WheelSlip>();
    ros2_gazebo_msgs_msg_WheelSlip_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_gazebo_msgs_WheelSlip_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_gazebo_msgs_msg_WheelSlip_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (gazebo_msgs::msg::WheelSlip*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_WheelSlip_common, MATLABROS2MsgInterface<gazebo_msgs::msg::WheelSlip>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_WheelSlip_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER