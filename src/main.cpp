#include <boost/program_options.hpp>
#include <iostream>

namespace po = boost::program_options;

int main(int argc, char* argv[])
{
    // Declare the supported options.
    std::ostringstream os;
    os << "Usage: hello...\n"
       << "Print hello world.\n";
    po::options_description desc(os.str());
    desc.add_options()("help", "display help message");

    po::variables_map vm;

    try
    {
        po::store(po::parse_command_line(argc, argv, desc), vm);
        po::notify(vm);
    }
    catch (std::exception& e)
    {
        std::cerr << e.what() << std::endl;
        std::cerr << desc << std::endl;
        return 1;
    }
    if (vm.count("help") > 0)
    {
        std::cout << desc << std::endl;
        return 0;
    }

    std::cout << "Hello, world!" << std::endl;
    return 0;
}
