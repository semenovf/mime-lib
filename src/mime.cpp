////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Vladislav Trifochkin
//
// This file is part of `mime-lib`.
//
// Changelog:
//      2023.05.02 Initial version.
//      2023.09.21 Rewritten.
////////////////////////////////////////////////////////////////////////////////
#include "pfs/mime.hpp"
#include <unordered_map>

namespace mime {

static std::unordered_map<std::string, mime_enum> const WELL_KNOWN_EXTENSIONS = {
      { ".txt" , mime_enum::text__plain }
    , { ".log" , mime_enum::text__plain }
    , { ".html", mime_enum::text__html  }
    , { ".htm" , mime_enum::text__html  }
    , { ".ogg" , mime_enum::audio__ogg  } // Ogg Vorbis Audio File
    , { ".wav" , mime_enum::audio__wav  } // WAVE Audio File
    , { ".mp4" , mime_enum::video__mp4  } // MPEG-4 Video
    , { ".bmp" , mime_enum::image__bmp  } // Bitmap Image
    , { ".gif" , mime_enum::image__gif  } // Graphical Interchange Format File
    , { ".ico" , mime_enum::image__vnd_microsoft_icon }
    , { ".jpeg", mime_enum::image__jpeg }
    , { ".jpg" , mime_enum::image__jpeg }
    , { ".png" , mime_enum::image__png  }
    , { ".tiff", mime_enum::image__tiff }
    , { ".tif" , mime_enum::image__tiff }
};

mime_enum mime_by_extension (pfs::filesystem::path const & path)
{
    if (path.empty())
        return mime_enum::unknown;

    auto ext = pfs::filesystem::utf8_encode(path.extension());

    if (ext.empty())
        return mime_enum::unknown;

    // Convert to lower case
    std::transform(ext.begin(), ext.end(), ext.begin(), [] (char ch) {
        return (ch <= 'Z' && ch >= 'A') ? ch - ('Z' - 'z') : ch;
    });

    auto pos = WELL_KNOWN_EXTENSIONS.find(ext);

    if (pos != WELL_KNOWN_EXTENSIONS.end())
        return pos->second;

    return mime_enum::unknown;
}

mime_enum mime_by_extension_fallback (pfs::filesystem::path const & path, mime_enum fallback)
{
    auto m = mime_by_extension(path);
    return m == mime_enum::unknown ? fallback : m;
}

} // namespace mime
