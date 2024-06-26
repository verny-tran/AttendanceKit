
#import <Foundation/Foundation.h>

#include "tensorflow_utils.h"
#include <pthread.h>
#include <unistd.h>
#include <fstream>
#include <queue>
#include <sstream>
#include <string>

namespace {
// Helper class used to load protobufs efficiently.
class IfstreamInputStream: public ::google::protobuf::io::CopyingInputStream {
public:
    explicit IfstreamInputStream(const std::string& file_name)
    : ifs_(file_name.c_str(), std::ios::in | std::ios::binary) {}
    ~IfstreamInputStream() { ifs_.close(); }
    
    int Read(void* buffer, int size) {
        if (!ifs_) {
            return -1;
        }
        ifs_.read(static_cast<char*>(buffer), size);
        return static_cast<int>(ifs_.gcount());
    }
    
private:
    std::ifstream ifs_;
};
}  // namespace

bool PortableReadFileToProto(const std::string& file_name,
                             ::google::protobuf::MessageLite* proto) {
    ::google::protobuf::io::CopyingInputStreamAdaptor stream(new IfstreamInputStream(file_name));
    stream.SetOwnsCopyingStream(true);
    ::google::protobuf::io::CodedInputStream coded_stream(&stream);
    // Total bytes hard limit / warning limit are set to 1GB and 512MB
    // respectively.
    coded_stream.SetTotalBytesLimit(1024LL << 20, 512LL << 20);
    return proto->ParseFromCodedStream(&coded_stream);
}

NSString* FilePathForResourceName(NSString* name, NSString* extension) {
    NSString* file_path =
    [[NSBundle mainBundle] pathForResource:name ofType:extension];
    if (file_path == NULL) {
        LOG(FATAL) << "Couldn't find '" << [name UTF8String] << "." << [extension UTF8String] << "' in bundle.";
        return nullptr;
    }
    
    return file_path;
}

tensorflow::Status LoadModel(NSString* file_name, NSString* file_type,
                             std::unique_ptr<tensorflow::Session>* session) {
    tensorflow::SessionOptions options;
    
    tensorflow::Session* session_pointer = nullptr;
    tensorflow::Status session_status =
    tensorflow::NewSession(options, &session_pointer);
    
    if (!session_status.ok()) {
        LOG(ERROR) << "Could not create TensorFlow Session: " << session_status;
        return session_status;
    }
    session->reset(session_pointer);
    
    tensorflow::GraphDef tensorflow_graph;
    
    NSString* model_path = FilePathForResourceName(file_name, file_type);
    if (!model_path) {
        LOG(ERROR) << "Failed to find model proto at" << [file_name UTF8String]
        << [file_type UTF8String];
        return tensorflow::errors::NotFound([file_name UTF8String],
                                            [file_type UTF8String]);
    }
    
    const bool read_proto_succeeded = PortableReadFileToProto([model_path UTF8String], &tensorflow_graph);
    
    if (!read_proto_succeeded) {
        LOG(ERROR) << "Failed to load model proto from" << [model_path UTF8String];
        return tensorflow::errors::NotFound([model_path UTF8String]);
    }
    
    tensorflow::Status create_status = (*session)->Create(tensorflow_graph);
    if (!create_status.ok()) {
        LOG(ERROR) << "Could not create TensorFlow Graph: " << create_status;
        return create_status;
    }
    
    return tensorflow::Status::OK();
}

tensorflow::Status LoadMemoryMappedModel(NSString* file_name, NSString* file_type,
                                         std::unique_ptr<tensorflow::Session>* session,
                                         std::unique_ptr<tensorflow::MemmappedEnv>* memmapped_env) {
    NSString* network_path = FilePathForResourceName(file_name, file_type);
    memmapped_env->reset(
                         new tensorflow::MemmappedEnv(tensorflow::Env::Default()));
    tensorflow::Status mmap_status =
    (memmapped_env->get())->InitializeFromFile([network_path UTF8String]);
    if (!mmap_status.ok()) {
        LOG(ERROR) << "MMap failed with " << mmap_status.error_message();
        return mmap_status;
    }
    
    tensorflow::GraphDef tensorflow_graph;
    tensorflow::Status load_graph_status = ReadBinaryProto(
                                                           memmapped_env->get(),
                                                           tensorflow::MemmappedFileSystem::kMemmappedPackageDefaultGraphDef,
                                                           &tensorflow_graph
                                                           );
    
    if (!load_graph_status.ok()) {
        LOG(ERROR) << "MMap load graph failed with "
        << load_graph_status.error_message();
        return load_graph_status;
    }
    
    tensorflow::SessionOptions options;
    // Disable optimizations on this graph so that constant folding doesn't
    // increase the memory footprint by creating new constant copies of the weight
    // parameters.
    options.config.mutable_graph_options()
    ->mutable_optimizer_options()
    ->set_opt_level(::tensorflow::OptimizerOptions::L0);
    options.env = memmapped_env->get();
    
    tensorflow::Session* session_pointer = nullptr;
    tensorflow::Status session_status =
    tensorflow::NewSession(options, &session_pointer);
    
    if (!session_status.ok()) {
        LOG(ERROR) << "Could not create TensorFlow Session: " << session_status;
        return session_status;
    }
    
    tensorflow::Status create_status = session_pointer->Create(tensorflow_graph);
    if (!create_status.ok()) {
        LOG(ERROR) << "Could not create TensorFlow Graph: " << create_status;
        return create_status;
    }
    
    session->reset(session_pointer);
    
    return tensorflow::Status::OK();
}

tensorflow::Status LoadLabels(NSString* file_name, NSString* file_type,
                              std::vector<std::string>* label_strings) {
    // Read the label list
    NSString* labels_path = FilePathForResourceName(file_name, file_type);
    
    if (!labels_path) {
        LOG(ERROR) << "Failed to find model proto at" << [file_name UTF8String]
        << [file_type UTF8String];
        return tensorflow::errors::NotFound([file_name UTF8String],
                                            [file_type UTF8String]);
    }
    
    std::ifstream t;
    t.open([labels_path UTF8String]);
    std::string line;
    
    while (t) {
        std::getline(t, line);
        label_strings->push_back(line);
    }
    t.close();
    
    return tensorflow::Status::OK();
}
