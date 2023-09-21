////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Vladislav Trifochkin
//
// This file is part of `mime-lib`.
//
// Changelog:
//      2023.09.21 Initial version.
////////////////////////////////////////////////////////////////////////////////
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#define PFS__TEST_ENABLED
#include "doctest.h"
#include "pfs/filesystem.hpp"
#include "pfs/mime.hpp"

namespace fs = pfs::filesystem;

TEST_CASE("mime_by_extension") {

    CHECK(mime::mime_by_extension(fs::path{"image.jpeg"}) == mime::mime_enum::image__jpeg);
    CHECK(mime::mime_by_extension(fs::path{"image.jpg"}) == mime::mime_enum::image__jpeg);
    CHECK(mime::mime_by_extension(fs::path{"image.JPEG"}) == mime::mime_enum::image__jpeg);
    CHECK(mime::mime_by_extension(fs::path{"image.jPg"}) == mime::mime_enum::image__jpeg);

    CHECK(mime::mime_by_extension(fs::path{"file.abracadabra"}) == mime::mime_enum::unknown);
}
