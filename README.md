<br />
<p align="center" width="100%">
    <img width="15%" src="https://github.com/verny-tran/AttendanceKit/blob/main/Legacy/Assets/Icons/Cropped/AttendanceKit.png"> 
</p>
<h1 align="center"> AttendanceKit </h1>

This is the official repository and **iOS** implementation of the role-based mobile applications for attendance checking using **facial recognition**, **UHF RFID** and **NFC** described in the papers ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) in [FDSE 2022](https://doi.org/10.1007/978-981-19-8069-5) and ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) in [SN Computer Science • Volume 4, 729 (2023)](https://link.springer.com/journal/42979).

This research was funded by Vietnam National University, Ho Chi Minh City (VNU-HCM) under grant number **C2022-28-10 (level C)** and is on-going with another grant in **level B**. Any opinions, findings, conclusions or recommendations expressed in this material are those of the authors and should not be attributed to their employers or funding sources.

## Table of contents
1. [Summary](#summary)
2. [News](#news)
3. [Applications](#applications)
4. [Inspiration](#inspiration)
5. [Compatibility](#compatibility)
6. [Dependencies](#dependencies)
7. [Pre-trained models](#models)
8. [Training data](#training)
9. [Performance](#performance)
10. [Reference](#reference)

---

## Summary <a name="summary"></a>
Traditional attendance monitoring has disadvantaged wasting time and resources. While an automatic attendance monitoring system enables students to check their attendance in offline classes. This paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29), we propose an **AttendanceKit** set of applications to automatically check their attendance using real-time **Ultra-High Frequency (UHF) RFID** technology combined with **face recognition** in a suite of mobile applications for institution, lecturers, parents, and students. This can assist us overcome the disadvantages of manual inspection and get a very precise outcome. 

<img align="middle" width="1000" src="https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Figures/Attendance%20checking%20flow.png">

The backend system’s real-time updates will trigger automatic push notifications to the students’ mobile devices, prompting them to access the app and verify their attendance. They will also include the attendance monitoring features that allow the instructor to evaluate or determine the attendance status of each student. After receiving a request from a student, the application enables lecturers to manually monitor attendance in the event of unforeseen student concerns. In addition, our technique can automatically compile reports and analysis on each student’s learning status in each class and the class overall to provide the lecturers, parents, and the institution with the aggregate percentage of students who are committed to attending class. Our experiments show that some initial simulations of the system provide a more complete picture of how the new system operates and interacts, followed by an evaluation based on the learning outcomes of the class. Our system takes time and accuracy into account. In addition, our results present a complete performance study of the system with RFID and genuine mobile devices, as well as a novel machine learning platform that can be deployed on actual devices in reality for commercial. 

<img align="middle" width="1000" src="https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Figures/Face%20recognition%20flow.png">

And also in the paper ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2), we will examine the differences in the implementation approaches of a face recognition model on actual mobile devices (iOS and Android), as well as its performance. Specifically, we will look at the discrepancies between these two categories. In particular, we will investigate the ways in which these distinctions influence the precision of face recognition predictions as well as the amount of work that is required of devices in order for them to use a machine learning model, examine the advantages and disadvantages of the model encoding approach that is shared by the **TensorFlow** and **Core ML** frameworks, as well as how it helps to the overall success of the **AttendanceKit** system.

__Contribution of this work__
- A set of **macOS** and **iOS** role-based usable and deployable applications, which is very new because few researchers can develop or try to implement anything on Apple platforms previously due to the difficulty of hardware dependency and its exclusivity. The algorithm is then fed a series of **5-second-long videos** containing the faces of students. A collection of student faces is compared with the image captured by the camera on the mobile device, and attendance is recorded if the two IDs matched, stored ID via vectors in the database after trained and current ID via mobile app.
- Utilizing the information system described, we continue to assess the performance of the learning outcomes to illustrate the utility of **automatic RFID, NFC** in improving the quality of learning. RFID and NFC tags and mobile device’s camera are combined to reach our current target of teaching or security-based facial. We leverage a Convolution Neural Network (CNN) **FaceNet** model, implemented in **TensorFlow's** and converted to **Core ML** `.mlmodel` format prior. The timing and precision of our system are then determined.
- By comparing the analysis on the two mobile platforms, we can determine the benefits and drawbacks of each model implementation method (**native framework**, **web API**, **model wrapping**, or **model converting**) and have a clear picture of which strategy to employ for similar systems that also include machine learning models on mobile applications.

## News <a name="news"></a>
| Date       | Update |
|------------|--------|
| 20.03.2024 | My thesis dissertation for the **BSc. degree in Computer Science** with the topic ["Autonomous attendance mobile applications based on Face Recognition and NFC"](https://it.hcmiu.edu.vn) has been successfully defended at the **International University - Vietnam National University, Ho Chi Minh City (HCMIU)**. |
| 04.12.2023 | The project [**C2022-28-10:** "Face recognition enhancement utilizing on-device machine learning"](https://ord.hcmiu.edu.vn/homepage/view/content?nid=129) **(level C)** has been **approved** by the committee from **Vietnam National University, Ho Chi Minh City (VNU-HCM)**. |
| 25.09.2023 | The article ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) has been **published**. |
| 30.07.2023 | A new project titled ["Developing a federated learning algorithm for autonomous attendance systems based on camera and long-range RFID"](https://ord.hcmiu.edu.vn/homepage/view/index) **(level B)** has been **submitted** to request a grant from **Vietnam National University, Ho Chi Minh City (VNU-HCM)**. |
| 13.07.2023 | The article ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) has been **accepted**. |
| 24.04.2023 | The article ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) has been **submitted**. |
| 03.01.2023 | The paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) has been **selected for publication in a special issue** of [SNCS](https://link.springer.com/journal/42979) journal. |
| 20.11.2022 | The paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) has been **published**. |
| 04.10.2022 | The paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) has been **accepted**. |
| 01.08.2022 | The paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) has been **submitted**. |

## Applications <a name="applications"></a>
There are many applications in the set

| RFID Dashboard |     Student    |   Institution  |    Lecturer    |
|      :---:     |      :---:     |      :---:     |      :---:     |
| ![](https://github.com/verny-tran/AttendanceKit/blob/main/Legacy/Assets/Icons/Cropped/Dashboard%20Icon.png) | ![](https://github.com/verny-tran/AttendanceKit/blob/main/Legacy/Assets/Icons/Cropped/Student.png) | ![](https://github.com/verny-tran/AttendanceKit/blob/main/Legacy/Assets/Icons/Cropped/Institution.png) | ![](https://github.com/verny-tran/AttendanceKit/blob/main/Legacy/Assets/Icons/Cropped/Lecturer.png) |
| git status     | git status     | git status     | git status     |
| git diff       | git diff       | git diff       | git diff       |

## Inspiration <a name="inspiration"></a>
The face recognition module of these applications is heavily inspired by the project [**enVision**](https://github.com/IDLabs-Gate/enVision) from [ID Labs](https://github.com/IDLabs-Gate).

## Compatibility <a name="compatibility"></a>
The code is tested using **TensorFlow** `1.7` and **Core ML** `3.0`  under **iOS** `15.0` with **Swift** `5.1`, **Java** `16.0` and **Python** `3.5`. 

__IMPORTANT:__ The project must be built with **Xcode** on a **macOS** device. While the **RFID Dashboard** desktop middleware app can be built with **IntelliJ**.

## Dependencies <a name="dependencies"></a>
This project is written in **Swift**, **Objective-C**, **Objective-C++**, **Java** and **Python**. Dependencies include:

### CocoaPods
```ruby
platform :ios, '15.0'
use_frameworks!

workspace 'AttendanceKit'

def pods
  pod 'TensorFlow-experimental'
  pod 'FaceCropper'
  pod 'Alamofire'
  pod 'RealmSwift'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'SDWebImage'
  pod 'RxSwift'
  pod 'RxCocoa'
end

target 'General' do
  project 'General'
  pods
end

target 'Student' do
  project 'Student'
  pods
end

target 'Institution' do
  project 'Institution'
  pods
end

target 'Lecturer' do
  project 'Lecturer'
  pods
end
```

To create the `AttendanceKit.xcworkspace`, run the following commands in **Terminal**. Replace `<project_folder>` with your cloned project root folder:
```bash
cd /Users/<project_folder>
pod install
```

If you don't have **CocoaPods** installed, install it by using this command:
```bash
sudo gem install cocoapods
```

### Gradle
The macOS **RFID Dashboard** application uses **Gradle** as its project build automation tool. Refresh the dependencies of the `dashboard.idea` project by running the following command:

```bash
gradle --refresh-dependencies clean build
```

## Pre-trained models <a name="models"></a>
| Model name      | LFW accuracy | Training dataset | Architecture |
|-----------------|--------------|------------------|-------------|
| [facenet.mlmodel](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Models/facenet.mlmodel) | 0.9945        | VGGFace2    | [Inception ResNet v1](https://github.com/davidsandberg/facenet/blob/master/src/models/inception_resnet_v1.py) |
| [facenet.pb](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Models/facenet.pb) | 0.9965        | VGGFace2      | [Inception ResNet v1](https://github.com/davidsandberg/facenet/blob/master/src/models/inception_resnet_v1.py) |
| [facenet.h5](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Models/facenet.h5) | 0.9905        | CASIA-WebFace      | [Inception ResNet v1](https://github.com/davidsandberg/facenet/blob/master/src/models/inception_resnet_v1.py) |

__NOTE:__ If you use any of the models, please do not forget to give proper credit to me, the [FaceNet](https://github.com/davidsandberg/facenet) authors and those providing the training dataset as well.

## Training data <a name="training"></a>
The [CASIA-WebFace](http://www.cbsr.ia.ac.cn/english/CASIA-WebFace-Database.html) dataset has been used for training. This training set consists of total of **453.453** images over **10.575** identities after face detection. Some performance improvement has been seen if the dataset has been filtered before training. Some more information about how this was done will come later.
The best performing model has been trained on the [VGGFace2](https://www.robots.ox.ac.uk/~vgg/data/vgg_face2/) dataset consisting of ~**3.3M** faces and ~**9.000** classes.

## Performance <a name="performance"></a>
The accuracy on LFW for the model [facenet.pb](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Models/facenet.pb) is `0.99650±0.00252`. A description of how to run the test can be found on the page [Validate on LFW](https://github.com/davidsandberg/facenet/wiki/Validate-on-lfw). 

__NOTE:__ The input images to the model need to be standardized using fixed image standardization (use the option `--use_fixed_image_standardization` when running e.g. `validate_on_lfw.py`).

## Reference <a name="reference"></a>
To cite the papers, please use these BibTex:
```bibtex
@inproceedings{tran2022attendancekit,
  title={AttendanceKit: a set of role-based mobile applications for automatic attendance checking with UHF RFID using realtime firebase and face recognition},
  author={Tran, Trung-Dung and Huynh, Kha-Tu and Nguyen, Phu-Quang and Ly, Tu-Nga},
  booktitle={International Conference on Future Data and Security Engineering},
  pages={432--446},
  year={2022},
  organization={Springer}
}
```

```bibtex
@article{tran2023wrap,
  title={To Wrap, or Not to Wrap: Examining the Distinctions Between Model Implementations of Face Recognition on Mobile Devices in an Automatic Attendance System},
  author={Tran, Trung-Dung and Ly, Tu-Nga},
  journal={SN Computer Science},
  volume={4},
  number={6},
  pages={729},
  year={2023},
  publisher={Springer}
}
```
