#define BOOST_TEST_MODULE "cpp_template"
#include <boost/test/unit_test.hpp>
#include <iostream>
#include <template/template.h>

void thrower()
{
    throw cpp_template::Exception("test exception");
}

BOOST_AUTO_TEST_CASE(Template)
{
    BOOST_CHECK_THROW(thrower(), cpp_template::Exception);
}
