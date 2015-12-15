#include <template/template.h>

namespace cpp_template
{

Exception::Exception(std::string message) : message_(std::move(message))
{
}

const char* Exception::what() const noexcept
{
    return message_.c_str();
}

} // namespace cpp_template
