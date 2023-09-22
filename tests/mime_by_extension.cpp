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

    struct {
        char const * filename;
        mime::mime_enum expected;
    } test_data[] = {
          { "text.txt"  , mime::mime_enum::text__plain }
        , { "text.tXt"  , mime::mime_enum::text__plain }
        , { "text.LOG"  , mime::mime_enum::text__plain }
        , { "site.html" , mime::mime_enum::text__html }
        , { "SITE.HTM"  , mime::mime_enum::text__html }
        , { "audio.ogg" , mime::mime_enum::audio__ogg }
        , { "audio.Wav" , mime::mime_enum::audio__wav }
        , { "video.MP4" , mime::mime_enum::video__mp4 }
        , { "image.BMP" , mime::mime_enum::image__bmp }
        , { "image.GIF" , mime::mime_enum::image__gif }
        , { "image.ICO" , mime::mime_enum::image__vnd_microsoft_icon }
        , { "image.png" , mime::mime_enum::image__png }
        , { "image.TIFF", mime::mime_enum::image__tiff }
        , { "image.tif" , mime::mime_enum::image__tiff }
        , { "image.jpeg", mime::mime_enum::image__jpeg }
        , { "image.jpg" , mime::mime_enum::image__jpeg }
        , { "image.JPEG", mime::mime_enum::image__jpeg }
        , { "image.jPg" , mime::mime_enum::image__jpeg }

        , { "", mime::mime_enum::unknown }
        , { "app", mime::mime_enum::unknown }
        , { "app.unknown", mime::mime_enum::unknown }
        , { "file.abracadabra", mime::mime_enum::unknown }
    };

    for (auto const elem: test_data) {
        CHECK_EQ(mime::mime_by_extension(fs::utf8_decode(elem.filename)), elem.expected);
    }
}
