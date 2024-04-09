
#ifndef TENSORFLOW_CONTRIB_IOS_EXAMPLES_CAMERA_TENSORFLOW_UTILS_H_
#define TENSORFLOW_CONTRIB_IOS_EXAMPLES_CAMERA_TENSORFLOW_UTILS_H_

#include <memory>
#include <vector>

#include "tensorflow/core/public/session.h"
#include "tensorflow/core/util/memmapped_file_system.h"
#include "third_party/eigen3/unsupported/Eigen/CXX11/Tensor"

// Reads a serialized GraphDef protobuf file from the bundle, typically
// created with the freeze_graph script. Populates the session argument with a
// Session object that has the model loaded.
tensorflow::Status LoadModel(NSString* file_name, NSString* file_type,
                             std::unique_ptr<tensorflow::Session>* session);

// Loads a model from a file that has been created using the
// convert_graphdef_memmapped_format tool. This bundles together a GraphDef
// proto together with a file that can be memory-mapped, containing the weight
// parameters for the model. This is useful because it reduces the overall
// memory pressure, since the read-only parameter regions can be easily paged
// out and don't count toward memory limits on iOS.
tensorflow::Status LoadMemoryMappedModel(NSString* file_name, NSString* file_type,
                                         std::unique_ptr<tensorflow::Session>* session,
                                         std::unique_ptr<tensorflow::MemmappedEnv>* memmapped_env);

// Takes a text file with a single label on each line, and returns a list.
tensorflow::Status LoadLabels(NSString* file_name, NSString* file_type,
                              std::vector<std::string>* label_strings);


#endif  // TENSORFLOW_CONTRIB_IOS_EXAMPLES_CAMERA_TENSORFLOW_UTILS_H_
