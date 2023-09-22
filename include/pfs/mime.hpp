////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Vladislav Trifochkin
//
// This file is part of `mime-lib`.
//
// Changelog:
//      2023.05.02 Initial version.
////////////////////////////////////////////////////////////////////////////////
#pragma once
#include "mime_enum.hpp"
#include "pfs/error.hpp"
#include "pfs/filesystem.hpp"
#include <string>
#include <system_error>

#ifndef MIME__STATIC
#   ifndef MIME__EXPORT
#       if _MSC_VER
#           if defined(MIME__EXPORTS)
#               define MIME__EXPORT __declspec(dllexport)
#           else
#               define MIME__EXPORT __declspec(dllimport)
#           endif
#       else
#           define MIME__EXPORT
#       endif
#   endif
#else
#   define MIME__EXPORT
#endif // !MIME__STATIC

namespace mime {

/**
 * Determines MIME type of file @a path by read it's header.
 */
MIME__EXPORT
mime_enum read_mime (pfs::filesystem::path const & path, pfs::error * perr = nullptr);

MIME__EXPORT
mime_enum read_mime_fallback (pfs::filesystem::path const & path
    , mime_enum fallback = mime_enum::fallback
    , pfs::error * perr = nullptr);

/**
 * Determines MIME type of file @a path by it's extension.
 */
MIME__EXPORT
mime_enum mime_by_extension (pfs::filesystem::path const & path);

MIME__EXPORT
mime_enum mime_by_extension_fallback (pfs::filesystem::path const & path
    , mime_enum fallback = mime_enum::fallback);

} // namespace pfs
