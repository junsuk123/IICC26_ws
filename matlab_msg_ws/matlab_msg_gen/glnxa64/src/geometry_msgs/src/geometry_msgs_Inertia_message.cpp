// Copyright 2020-2022 The MathWorks, Inc.
// Common copy functions for geometry_msgs/Inertia
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
#include "geometry_msgs/msg/inertia.hpp"
#include "visibility_control.h"
#include "class_loader/multi_library_class_loader.hpp"
#include "ROS2PubSubTemplates.hpp"
class GEOMETRY_MSGS_EXPORT ros2_geometry_msgs_msg_Inertia_common : public MATLABROS2MsgInterface<geometry_msgs::msg::Inertia> {
  public:
    virtual ~ros2_geometry_msgs_msg_Inertia_common(){}
    virtual void copy_from_struct(geometry_msgs::msg::Inertia* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const geometry_msgs::msg::Inertia* msg, MultiLibLoader loader, size_t size = 1);
};
  void ros2_geometry_msgs_msg_Inertia_common::copy_from_struct(geometry_msgs::msg::Inertia* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //m
        const matlab::data::TypedArray<double> m_arr = arr["m"];
        msg->m = m_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'm' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'm' is wrong type; expected a double.");
    }
    try {
        //com
        const matlab::data::StructArray com_arr = arr["com"];
        auto msgClassPtr_com = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
        msgClassPtr_com->copy_from_struct(&msg->com,com_arr[0],loader);
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'com' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'com' is wrong type; expected a struct.");
    }
    try {
        //ixx
        const matlab::data::TypedArray<double> ixx_arr = arr["ixx"];
        msg->ixx = ixx_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'ixx' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'ixx' is wrong type; expected a double.");
    }
    try {
        //ixy
        const matlab::data::TypedArray<double> ixy_arr = arr["ixy"];
        msg->ixy = ixy_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'ixy' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'ixy' is wrong type; expected a double.");
    }
    try {
        //ixz
        const matlab::data::TypedArray<double> ixz_arr = arr["ixz"];
        msg->ixz = ixz_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'ixz' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'ixz' is wrong type; expected a double.");
    }
    try {
        //iyy
        const matlab::data::TypedArray<double> iyy_arr = arr["iyy"];
        msg->iyy = iyy_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'iyy' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'iyy' is wrong type; expected a double.");
    }
    try {
        //iyz
        const matlab::data::TypedArray<double> iyz_arr = arr["iyz"];
        msg->iyz = iyz_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'iyz' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'iyz' is wrong type; expected a double.");
    }
    try {
        //izz
        const matlab::data::TypedArray<double> izz_arr = arr["izz"];
        msg->izz = izz_arr[0];
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'izz' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'izz' is wrong type; expected a double.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T ros2_geometry_msgs_msg_Inertia_common::get_arr(MDFactory_T& factory, const geometry_msgs::msg::Inertia* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","m","com","ixx","ixy","ixz","iyy","iyz","izz"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("geometry_msgs/Inertia");
    // m
    auto currentElement_m = (msg + ctr)->m;
    outArray[ctr]["m"] = factory.createScalar(currentElement_m);
    // com
    auto currentElement_com = (msg + ctr)->com;
    auto msgClassPtr_com = getCommonObject<geometry_msgs::msg::Vector3>("ros2_geometry_msgs_msg_Vector3_common",loader);
    outArray[ctr]["com"] = msgClassPtr_com->get_arr(factory, &currentElement_com, loader);
    // ixx
    auto currentElement_ixx = (msg + ctr)->ixx;
    outArray[ctr]["ixx"] = factory.createScalar(currentElement_ixx);
    // ixy
    auto currentElement_ixy = (msg + ctr)->ixy;
    outArray[ctr]["ixy"] = factory.createScalar(currentElement_ixy);
    // ixz
    auto currentElement_ixz = (msg + ctr)->ixz;
    outArray[ctr]["ixz"] = factory.createScalar(currentElement_ixz);
    // iyy
    auto currentElement_iyy = (msg + ctr)->iyy;
    outArray[ctr]["iyy"] = factory.createScalar(currentElement_iyy);
    // iyz
    auto currentElement_iyz = (msg + ctr)->iyz;
    outArray[ctr]["iyz"] = factory.createScalar(currentElement_iyz);
    // izz
    auto currentElement_izz = (msg + ctr)->izz;
    outArray[ctr]["izz"] = factory.createScalar(currentElement_izz);
    }
    return std::move(outArray);
  } 
class GEOMETRY_MSGS_EXPORT ros2_geometry_msgs_Inertia_message : public ROS2MsgElementInterfaceFactory {
  public:
    virtual ~ros2_geometry_msgs_Inertia_message(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType /*type*/);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType /*type*/);
    virtual std::shared_ptr<void> generateCppMessage(ElementType /*type*/, const matlab::data::StructArray& /* arr */, MultiLibLoader /* loader */, std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
    virtual matlab::data::StructArray generateMLMessage(ElementType  /*type*/ ,void*  /* msg */, MultiLibLoader /* loader */ , std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* /*commonObjMap*/);
};  
  std::shared_ptr<MATLABPublisherInterface> 
          ros2_geometry_msgs_Inertia_message::generatePublisherInterface(ElementType /*type*/){
    return std::make_shared<ROS2PublisherImpl<geometry_msgs::msg::Inertia,ros2_geometry_msgs_msg_Inertia_common>>();
  }
  std::shared_ptr<MATLABSubscriberInterface> 
         ros2_geometry_msgs_Inertia_message::generateSubscriberInterface(ElementType /*type*/){
    return std::make_shared<ROS2SubscriberImpl<geometry_msgs::msg::Inertia,ros2_geometry_msgs_msg_Inertia_common>>();
  }
  std::shared_ptr<void> ros2_geometry_msgs_Inertia_message::generateCppMessage(ElementType /*type*/, 
                                           const matlab::data::StructArray& arr,
                                           MultiLibLoader loader,
                                           std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>* commonObjMap){
    auto msg = std::make_shared<geometry_msgs::msg::Inertia>();
    ros2_geometry_msgs_msg_Inertia_common commonObj;
    commonObj.mCommonObjMap = commonObjMap;
    commonObj.copy_from_struct(msg.get(), arr[0], loader);
    return msg;
  }
  matlab::data::StructArray ros2_geometry_msgs_Inertia_message::generateMLMessage(ElementType  /*type*/ ,
                                                    void*  msg ,
                                                    MultiLibLoader  loader ,
                                                    std::map<std::string,std::shared_ptr<MATLABROS2MsgInterfaceBase>>*  commonObjMap ){
    ros2_geometry_msgs_msg_Inertia_common commonObj;	
    commonObj.mCommonObjMap = commonObjMap;	
    MDFactory_T factory;
    return commonObj.get_arr(factory, (geometry_msgs::msg::Inertia*)msg, loader);			
 }
#include "class_loader/register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(ros2_geometry_msgs_msg_Inertia_common, MATLABROS2MsgInterface<geometry_msgs::msg::Inertia>)
CLASS_LOADER_REGISTER_CLASS(ros2_geometry_msgs_Inertia_message, ROS2MsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER