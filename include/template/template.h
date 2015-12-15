#ifndef TEMPLATE_H
#define TEMPLATE_H

#include <exception>
#include <string>

namespace cpp_template
{

/** Base exception for the template library */
class Exception : public std::exception
{
public:
    explicit Exception(std::string message);
    const char* what() const noexcept override;

private:
    std::string message_;
};

} // namespace cpp_template

#endif // TEMPLATE_H
