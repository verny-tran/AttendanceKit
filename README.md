<br />
<p align="center" width="100%">
    <img width="15%" src="https://github.com/verny-tran/AttendanceKit/blob/main/Legacy/Assets/Icons/Cropped/AttendanceKit.png"> 
</p>
<h1 align="center"> AttendanceKit </h1>

This is the official repository and **iOS** implementation of the role-based mobile applications for attendance checking using **facial recognition**, **UHF RFID** and **NFC** described in the papers ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) in [FDSE 2022](https://doi.org/10.1007/978-981-19-8069-5) and ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) in [SN Computer Science • Volume 4, 729 (2023)](https://link.springer.com/journal/42979).

This research was funded by [Vietnam National University, Ho Chi Minh City (VNU-HCM)](https://vnuhcm.edu.vn) under grant number [**C2022-28-10**](https://ord.hcmiu.edu.vn/homepage/view/content?nid=129) **(level C)** and is on-going with another grant in **level B**. Any opinions, findings, conclusions or recommendations expressed in this material are those of the authors and should not be attributed to their employers or funding sources.

## Contents
1. [Summary](#summary)
2. [News](#news)
3. [Applications](#applications)
4. [Inspiration](#inspiration)
5. [Compatibility](#compatibility)
6. [Dependencies](#dependencies)
7. [Directory structure](#directory)
8. [Pre-trained models](#models)
9. [Training data](#training)
10. [Performance](#performance)
11. [Reference](#reference)
12. [License](#license)

## Summary <a name="summary"></a>
The research project proposes an ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) system that uses real-time **Ultra-High Frequency (UHF) RFID** and **NFC** technology combined with **face recognition** to automatically check students' attendance in offline classes, packaged as a suite of mobile applications for *Institution*, *Lecturers* and *Students* to overcoming the disadvantages of manual inspection.

<img align="middle" width="1000" src="https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Figures/Attendance%20checking%20flow.png">

The backend system will send **real-time notifications** to students' mobile devices, allowing them to verify attendance. It also features *attendance monitoring*, allowing instructors to evaluate student status. The system can also **compile reports** on student learning status, providing insights for lecturers, parents, and institutions.

<img align="middle" width="1000" src="https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Figures/Admin%20module.png">

The diagram depicted above demonstrates the procedural flow of the **Custom Admin Module**, which addresses [Firebase Authentication](https://firebase.google.com/docs/auth)'s limitation by allowing one **end-user** (*Institution*) to create accounts for **other end-users** (*Student*) using a [Node.js](https://nodejs.org) module of custom functions.

Our system also takes **time and accuracy** into account. In addition, the results present a complete performance study of the system with [RFID](https://en.wikipedia.org/wiki/Radio-frequency_identification), [NFC](https://en.wikipedia.org/wiki/Near-field_communication) and genuine mobile devices, as well as a novel machine learning platform that *can be deployed on actual devices* in reality for commercial. 

<img align="middle" width="1000" src="https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Figures/Face%20recognition%20flow.png">

And also the article ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) explores the implementation approaches of face recognition models on mobile devices, focusing on their performance and precision. It explores the advantages and disadvantages of the [TensorFlow](https://www.tensorflow.org) and [Core ML](https://developer.apple.com/machine-learning/core-ml) model encoding approach, and its impact on the overall success of the **AttendanceKit** system.

__Contribution of this work:__
- A set of **macOS** and **iOS** role-based attendance checking usable and deployable applications for Apple platforms.
- Assess the performance of the learning outcomes to illustrate the utility of **automatic RFID, NFC** in improving the quality of learning.
- Custom **admin module** to modify the behavior of **Firebase Authentication**, allows an end-user to create accounts for other end-users.
- Algorithms fed with a series of **5-second-long videos** containing the face samples of students and and how to optimize the recognition process in real-time on mobile devices's camera.
- Leverage the CNN **FaceNet** model, implemented in **TensorFlow's** and how to convert to the native **Core ML** `.mlmodel` format prior. Examining the approaches of **Create ML**, **turicreate** and **coremltools**.
- Determined timing and precision by comparing the analysis on the two mobile platforms, and the benefits and drawbacks of each model implementation method (**native framework**, **web API**, **model wrapping**, or **model converting**) to have a clear picture of which strategy to employ for similar systems.

## News <a name="news"></a>
| Date       | Update |
|------------|--------|
| 20.03.2024 | My thesis dissertation for the **BSc. degree in Computer Science** with the topic ["Autonomous attendance mobile applications based on Face Recognition and NFC"](https://it.hcmiu.edu.vn) has been successfully defended at the **International University - Vietnam National University, Ho Chi Minh City (HCMIU)**. |
| 04.12.2023 | The project [**C2022-28-10:** "Face recognition enhancement utilizing on-device machine learning"](https://ord.hcmiu.edu.vn/homepage/view/content?nid=129) **(level C)** has been **approved** by the committee from **Vietnam National University, Ho Chi Minh City (VNU-HCM)**. |
| 25.09.2023 | The article ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) has been **published**. |
| 30.07.2023 | A new project titled ["Developing a federated learning algorithm for autonomous attendance systems based on camera and long-range RFID"](https://ord.hcmiu.edu.vn/homepage/view/index) **(level B)** has been **submitted** to request a grant from **Vietnam National University, Ho Chi Minh City (VNU-HCM)**. |
| 13.07.2023 | The article ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) has been **accepted**. |
| 24.04.2023 | The article ["**To Wrap, or Not to Wrap: ...**"](https://doi.org/10.1007/s42979-023-02185-2) has been **submitted**. |
| 03.01.2023 | The paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) has been **selected for publication** in a **special issue** of [SNCS](https://link.springer.com/journal/42979) journal. |
| 20.11.2022 | The paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) has been **published**. |
| 04.10.2022 | The paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) has been **accepted**. |
| 01.08.2022 | The paper ["**AttendanceKit: ...**"](https://doi.org/10.1007/978-981-19-8069-5_29) has been **submitted**. |

## Applications <a name="applications"></a>
There are many items in the **AttendanceKit** set of applications, including: **Student**, **Institution**, **Lecturer** (iOS), and **RFID Dashboard** (macOS).

|     Student    |   Institution  |    Lecturer    | RFID Dashboard |
|      :---:     |      :---:     |      :---:     |      :---:     |
| ![](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Icons/Student.png) | ![](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Icons/Institution.png) | ![](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Icons/Lecturer.png) | ![](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Icons/RFID%20Dashboard.png) |
| Face recognition is used as biometric security for all students when checking attendance. | To collect student face samples, class scheduling, assign tags, and classrooms. | For lecturers to view attendance reports and change schedules. | For connecting to RFID antennas to read and display tag IDs, act as admin application to compose notifications for mobile devices. |

## Inspiration <a name="inspiration"></a>
The **face recognition module** of these applications is heavily inspired by the project [**enVision**](https://github.com/IDLabs-Gate/enVision) from [ID Labs](https://github.com/IDLabs-Gate).

## Compatibility <a name="compatibility"></a>
![iOS](https://img.shields.io/badge/iOS-15.0-blue)
![macOS](https://img.shields.io/badge/macOS-12.0-green)
![TensorFlow](https://img.shields.io/badge/TensorFlow-1.7-red)
![Core ML](https://img.shields.io/badge/Core_ML-3.0-turquoise)
![Swift](https://img.shields.io/badge/Swift-5.1-orange)
![Java](https://img.shields.io/badge/Java-16.0-yellow)
![Python](https://img.shields.io/badge/Python-3.5-purple)

The code is tested using [TensorFlow](https://www.tensorflow.org) `1.7` and [Core ML](https://developer.apple.com/machine-learning/core-ml) `3.0` under **iOS** `15.0`, **macOS** `12.0` with **Swift** `5.1`, **Java** `16.0` and **Python** `3.5`. 

__IMPORTANT:__ The project must be built with [Xcode](https://developer.apple.com/xcode) on a **macOS** device. While the **RFID Dashboard** desktop middleware app can be built with [IntelliJ](https://www.jetbrains.com/idea).

## Dependencies <a name="dependencies"></a>
This project is written in **Swift**, **Objective-C**, **Objective-C++**, **Java** and **Python**. Dependencies include:

### CocoaPods
[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. If you don't have **CocoaPods** installed, install it by using this command:
```bash
$ sudo gem install cocoapods
```

To integrate all of the necessary pods into the **Xcode** workspace using **CocoaPods**, specify it in your `Podfile`:
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
$ cd /Users/<project_folder>
$ pod install
```

### Gradle
The macOS **RFID Dashboard** application uses [Gradle](https://gradle.org) as it's project build automation tool. Refresh the dependencies of the `dashboard.idea` project by running the following command:

```bash
$ gradle --refresh-dependencies clean build
```

## Directory structure <a name="directory"></a>
__IMPORTANT:__ Download the **FaceNet** TensorFlow model ~`87.4 MB` from [here](https://github.com/verny-tran/AttendanceKit/blob/main/Resources/Models/facenet.pb) and place it into the *ML* group folders of all `.xcodeproj` in the `AttendanceKit.xcworkspace`.

The directory should look like this:
```shell
┌── Institution/
  ┌── ML/
    ┌── facenet.pb
    ├── tensorflow_utils.h
    ├── ...
    ├── tfWrap.h
    └── tfWrap.mm
  ├── ...
  └── View/
  
├── Lecturer/
  ┌── ML/
    ┌── facenet.pb
    ├── tensorflow_utils.h
    ├── ...
    ├── tfWrap.h
    └── tfWrap.mm
  ├── ...
  └── View/

└── Student/
  ┌── ML/
    ┌── facenet.pb
    ├── tensorflow_utils.h
    ├── ...
    ├── tfWrap.h
    └── tfWrap.mm
  ├── ...
  └── View/
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
To cite the papers, please use these **BibTex**:
```bibtex
@inproceedings{tran2022attendancekit,
  title={A set of Role-Based Mobile Applications for Automatic Attendance Checking with UHF RFID Using Realtime Firebase and Face Recognition},
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

## License <a name="license"></a>
**AttendanceKit** is open-sourced under the **CC0-1.0** license. See `LICENSE` for more details.
