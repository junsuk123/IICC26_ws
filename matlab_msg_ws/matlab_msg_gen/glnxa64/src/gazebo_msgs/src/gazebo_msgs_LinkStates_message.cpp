// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/LinkStates
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
#include "gazebo_msgs/msg/link_states.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_LinkStates_common : public MATLABROS2MsgInterface<gazebo_msgs::msg::LinkStates> {
  public:
    virtual ~ros2_gazebo_msgs_msg_LinkStates_common(){}
    virtual void copy_from_struct(gazebo_msgs::msg::LinkStates* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::msg::LinkStates* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_LinkStates_common::copy_from_struct(gazebo_msgs::msg::LinkStates* msg, const matlab::data::Struct& arr,
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
        //pose
        const matlab::data::StructArray pose_arr = arr["pose"];
        for (auto _posearr : pose_arr) {
        	geometry_msgs::msg::Pose _val;
        auto msgClassPtr_pose = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
        msgClassPtr_pose->copy_from_struct(&_val,_posearr,loader);
        	msg->pose.push_back(_val);
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'pose' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'pose' is wrong type; expected a struct.");
    }
    try {
        //twist
        const matlab::data::StructArray twist_arr = arr["twist"];
        for (auto _twistarr : twist_arr) {
        	geometry_msgs::msg::Twist _val;
        auto msgClassPtr_twist = getCommonObject<geometry_msgs::msg::Twist>("ros2_geometry_msgs_msg_Twist_common",loader);
        msgClassPtr_twist->copy_from_struct(&_val,_twistarr,loader);
        	msg->twist.push_back(_val);
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'twist' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'twist' is wrong type; expected a struct.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_LinkStates_common::get_arr(MDFactory_T& factory, const gazebo_msgs::msg::LinkStates* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","name","pose","twist"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/LinkStates");
    // name
    auto currentElement_name = (msg + ctr)->name;
    auto nameoutCell = factory.createCellArray({currentElement_name.size(),1});
    for(size_t idxin = 0; idxin < currentElement_name.size(); ++ idxin){
    	nameoutCell[idxin] = factory.createCharArray(currentElement_name[idxin]);
    }
    outArray[ctr]["name"] = nameoutCell;
    // pose
    auto currentElement_pose = (msg + ctr)->pose;
    auto msgClassPtr_pose = getCommonObject<geometry_msgs::msg::Pose>("ros2_geometry_msgs_msg_Pose_common",loader);
    outArray[ctr]["pose"] = msgClassPtr_pose->get_arr(factory,&currentElement_pose[0],loader,currentElement_pose.size());
    // twist
    auto currentElement_twist = (msg + ctr)->twist;
    auto msgClassPtr_twist = getCommonObject<geometry_msgs::msg::Twist>("ros2_geometry_msgs_msg_Twist_common",loader);
    outArray[ctr]["twist"] = msgClassPtr_twist->get_arr(factory,&currentElement_twist[0],loader,currentElement_twist.size());
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_LinkStates_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_LinkStates_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_LinkStates_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<gazebo_msgs::msg::LinkStates,ros2_gazebo_msgs_msg_LinkStates_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_gazebo_msgs_LinkStates_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::msg::LinkStates,ros2_gazebo_msgs_msg_LinkStates_common>>();
  }
  std::shared_ptr<void> ros2_gazebo_msgs_LinkStates_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<gazebo_msgs::msg::LinkStates>();
    ros2_gazebo_msgs_msg_LinkStates_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_gazebo_msgs_LinkStates_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_gazebo_msgs_msg_LinkStates_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (gazebo_msgs::msg::LinkStates*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_LinkStates_common, MATLABROS2MsgInterface<gazebo_msgs::msg::LinkStates>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_LinkStates_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER