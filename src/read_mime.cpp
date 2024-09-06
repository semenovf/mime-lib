////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Vladislav Trifochkin
//
// This file is part of `mime-lib`.
//
// Changelog:
//      2023.05.02 Initial version.
//      2023.09.21 Rewritten.
////////////////////////////////////////////////////////////////////////////////
#include "pfs/i18n.hpp"
#include "pfs/mime.hpp"
#include "pfs/string_view.hpp"
#include <system_error>
#include <utility>

#if _MSC_VER
#   include <sys/types.h>
#   include <fcntl.h>
#else
#   include <sys/types.h>
#   include <fcntl.h>
#   include <unistd.h>
#endif

// Useful references
// https://docs.fileformat.com/

namespace mime {

namespace fs = pfs::filesystem;
using string_view = pfs::string_view;

static std::pair<mime_enum, string_view> const HEADERS[] = {
      { mime_enum::application__msword, string_view{"\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1"}} // Microsoft Word 6.0 Document
    , { mime_enum::application__pdf, string_view{"\x25\x50\x44\x46\x2D\x31\x2E"}}
    , { mime_enum::application__vnd_rar, string_view{"Rar!"}}
    , { mime_enum::application__x_dosexec, string_view{"MZ"}} // DOS/Windows executables/DLL
    , { mime_enum::audio__mpeg, string_view{"ID3"}} // MP3 with ID3 metadata
    , { mime_enum::audio__ogg, string_view{"OggS"}}
    , { mime_enum::audio__wav, string_view{"RIFF"}}
    , { mime_enum::image__bmp, string_view{"BM"}}
    , { mime_enum::image__gif, string_view{"GIF8"}}
    , { mime_enum::image__vnd_microsoft_icon, string_view{"\x00\x00\x01\x00"}}
    , { mime_enum::image__jpeg, string_view{"\xFF\xD8\xFF" }}
    , { mime_enum::image__png , string_view{"\x89\x50\x4E\x47\x0D\x0A\x1A\x0A"}}
    , { mime_enum::image__tiff, string_view{"II*"}}
    , { mime_enum::image__tiff, string_view{"MM*"}}
};

class mime_mapping
{
    std::size_t _maxlen = 0;

public:
    mime_mapping ()
    {
        for (auto const & h: HEADERS)
            _maxlen = (std::max)(_maxlen, h.second.size());
    }

    std::size_t maxlen () const noexcept
    {
        return _maxlen;
    }

    mime_enum get_mime (string_view header) const noexcept
    {
        for (auto const & h: HEADERS) {
            if (pfs::starts_with(header, h.second))
                return h.first;
        }

        return mime_enum::unknown;
    }
};

mime_enum read_mime (pfs::filesystem::path const & path, pfs::error * perr)
{
    static mime_mapping const __mime_mapping;
    pfs::error err;

    do {
        std::error_code ec;

        if (!fs::exists(path, ec)) {
            err = pfs::error {
                  ec ? ec : std::make_error_code(std::errc::no_such_file_or_directory)
                , fs::utf8_encode(path)
            };
            break;
        }

        if (!fs::is_regular_file(path, ec)) {
            err = pfs::error {
                  std::make_error_code(std::errc::no_such_file_or_directory)
                , fs::utf8_encode(path)
                , tr::_("expected regular file")
            };

            break;
        }

#if _MSC_VER
        auto h = ::_open(fs::utf8_encode(path).c_str(), O_RDONLY);
#else
        auto h = ::open(fs::utf8_encode(path).c_str(), O_RDONLY);
#endif

        if (h < 0) {
            err = pfs::error {
                  pfs::get_last_system_error()
                , fs::utf8_encode(path)
            };
            break;
        }

        std::vector<char> buffer(__mime_mapping.maxlen(), 0);

#if _MSC_VER
        auto n = ::_read(h, buffer.data(), static_cast<unsigned int>(buffer.size()));
#else
        auto n = ::read(h, buffer.data(), buffer.size());
#endif

        if (n < 0) {
            err = pfs::error {
                  pfs::get_last_system_error()
                , fs::utf8_encode(path)
                , tr::_("read file header")
            };
        }

        if (n == 0)
            return mime_enum::unknown;

        return __mime_mapping.get_mime(string_view{buffer.data(), static_cast<std::size_t>(n)});
    } while (false);

    if (!perr)
        throw err;

    *perr = std::move(err);
    return mime_enum::unknown;
}

mime_enum read_mime_fallback (pfs::filesystem::path const & path
    , mime_enum fallback, pfs::error * perr)
{
    auto m = read_mime(path, perr);
    return m == mime_enum::unknown ? fallback : m;
}

} // namespace mime
