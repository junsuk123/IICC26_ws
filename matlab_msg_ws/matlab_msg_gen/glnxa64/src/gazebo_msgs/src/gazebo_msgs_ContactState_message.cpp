// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for gazebo_msgs/ContactState
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
#include "gazebo_msgs/msg/contact_state.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_msg_ContactState_common : public MATLABROS2MsgInterface<gazebo_msgs::msg::ContactState> {
  public:
    virtual ~ros2_gazebo_msgs_msg_ContactState_common(){}
    virtual void copy_from_struct(gazebo_msgs::msg::ContactState* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const gazebo_msgs::msg::ContactState* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_gazebo_msgs_msg_ContactState_common::copy_from_struct(gazebo_msgs::msg::ContactState* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //info
        const matlab::data::CharArray info_arr = arr["info"];
        msg->info = info_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'info' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'info' is wrong type; expected a string.");
    }
    try {
        //collision1_name
        const matlab::data::CharArray collision1_name_arr = arr["collision1_name"];
        msg->collision1_name = collision1_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'collision1_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'collision1_name' is wrong type; expected a string.");
    }
    try {
        //collision2_name
        const matlab::data::CharArray collision2_name_arr = arr["collision2_name"];
        msg->collision2_name = collision2_name_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'collision2_name' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'collision2_name' is wrong type; expected a string.");
    }
    try {
        //wrenches
        const matlab::data::StructArray wrenches_arr = arr["wrenches"];
        for (auto _wrenchesarr : wrenches_arr) {
        	geometry_msgs::msg::Wrench _val;
        auto msgClassPtr_wrenches = getCommonObject<geometry_msgs::msg::Wrench>("ros2_geometry_msgs_msg_Wrench_common",loader);
        msgClassPtr_wrenches->copy_from_struct(&_val,_wrenchesarr,loader);
        	msg->wrenches.push_back(_val);
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'wrenches' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'wrenches' is wrong type; expected a struct.");
    }
    try {
        //total_wrench
        const matlab::data::StructArray total_wrench_arr = arr["total_wrench"];
        auto msgClassPtr_total_wrench = getCommonObject<geometry_msgs::msg::Wrench>("ros2_geometry_msgs_msg_Wrench_common",loader);
        msgClassPtr_total_wrench->copy_from_struct(&msg->total_wrench,total_wrench_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'total_wrench' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'total_wrench' is wrong type; expected a struct.");
    }
    try {
        //contact_positions
        const matlab::data::StructArray contact_positions_arr = arr["contact_positions"];
        for (auto _contact_positionsarr : contact_positions_arr) {
        	geometry_msgs::msg::Vector3 _val;
        auto msgClassPtr_contact_positions = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
        msgClassPtr_contact_positions->copy_from_struct(&_val,_contact_positionsarr,loader);
        	msg->contact_positions.push_back(_val);
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'contact_positions' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'contact_positions' is wrong type; expected a struct.");
    }
    try {
        //contact_normals
        const matlab::data::StructArray contact_normals_arr = arr["contact_normals"];
        for (auto _contact_normalsarr : contact_normals_arr) {
        	geometry_msgs::msg::Vector3 _val;
        auto msgClassPtr_contact_normals = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
        msgClassPtr_contact_normals->copy_from_struct(&_val,_contact_normalsarr,loader);
        	msg->contact_normals.push_back(_val);
        }
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'contact_normals' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'contact_normals' is wrong type; expected a struct.");
    }
    try {
        //depths
        const matlab::data::TypedArray<double> depths_arr = arr["depths"];
        size_t nelem = depths_arr.getNumberOfElements();
        	msg->depths.resize(nelem);
        	std::copy(depths_arr.begin(), depths_arr.begin()+nelem, msg->depths.begin());
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'depths' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'depths' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_gazebo_msgs_msg_ContactState_common::get_arr(MDFactory_T& factory, const gazebo_msgs::msg::ContactState* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","info","collision1_name","collision2_name","wrenches","total_wrench","contact_positions","contact_normals","depths"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("gazebo_msgs/ContactState");
    // info
    auto currentElement_info = (msg + ctr)->info;
    outArray[ctr]["info"] = factory.createCharArray(currentElement_info);
    // collision1_name
    auto currentElement_collision1_name = (msg + ctr)->collision1_name;
    outArray[ctr]["collision1_name"] = factory.createCharArray(currentElement_collision1_name);
    // collision2_name
    auto currentElement_collision2_name = (msg + ctr)->collision2_name;
    outArray[ctr]["collision2_name"] = factory.createCharArray(currentElement_collision2_name);
    // wrenches
    auto currentElement_wrenches = (msg + ctr)->wrenches;
    auto msgClassPtr_wrenches = getCommonObject<geometry_msgs::msg::Wrench>("ros2_geometry_msgs_msg_Wrench_common",loader);
    outArray[ctr]["wrenches"] = msgClassPtr_wrenches->get_arr(factory,&currentElement_wrenches[0],loader,currentElement_wrenches.size());
    // total_wrench
    auto currentElement_total_wrench = (msg + ctr)->total_wrench;
    auto msgClassPtr_total_wrench = getCommonObject<geometry_msgs::msg::Wrench>("ros2_geometry_msgs_msg_Wrench_common",loader);
    outArray[ctr]["total_wrench"] = msgClassPtr_total_wrench->get_arr(factory, &currentElement_total_wrench, loader);
    // contact_positions
    auto currentElement_contact_positions = (msg + ctr)->contact_positions;
    auto msgClassPtr_contact_positions = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
    outArray[ctr]["contact_positions"] = msgClassPtr_contact_positions->get_arr(factory,&currentElement_contact_positions[0],loader,currentElement_contact_positions.size());
    // contact_normals
    auto currentElement_contact_normals = (msg + ctr)->contact_normals;
    auto msgClassPtr_contact_normals = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
    outArray[ctr]["contact_normals"] = msgClassPtr_contact_normals->get_arr(factory,&currentElement_contact_normals[0],loader,currentElement_contact_normals.size());
    // depths
    auto currentElement_depths = (msg + ctr)->depths;
    outArray[ctr]["depths"] = factory.createArray<gazebo_msgs::msg::ContactState::_depths_type::const_iterator, double>({currentElement_depths.size(), 1}, currentElement_depths.begin(), currentElement_depths.end());
    }
    return std::move(outArray);
  } 
class GAZEBO_MSGS_EXPORT ros2_gazebo_msgs_ContactState_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_gazebo_msgs_ContactState_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_gazebo_msgs_ContactState_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<gazebo_msgs::msg::ContactState,ros2_gazebo_msgs_msg_ContactState_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_gazebo_msgs_ContactState_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<gazebo_msgs::msg::ContactState,ros2_gazebo_msgs_msg_ContactState_common>>();
  }
  std::shared_ptr<void> ros2_gazebo_msgs_ContactState_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<gazebo_msgs::msg::ContactState>();
    ros2_gazebo_msgs_msg_ContactState_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_gazebo_msgs_ContactState_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_gazebo_msgs_msg_ContactState_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (gazebo_msgs::msg::ContactState*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_msg_ContactState_common, MATLABROS2MsgInterface<gazebo_msgs::msg::ContactState>)
CLASS_LOADER_REGISTER_CLASS(ros2_gazebo_msgs_ContactState_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER