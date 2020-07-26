//
//  MimeTypeFinder.swift
//  ChannelizeUI
//
//  Created by bigstep on 4/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation

internal let DEFAULT_MIME_TYPE = "application/octet-stream"

/*
    html => HTML
    htm Y
    shtml
    css y
    xml => y
    gif
    jpeg
    jpg => Y
    js
    png => y
    tif
    tiff
    wbmp
    ico
    jng
    bmp
    svg
    svgz
    webp
    json
    doc => y
    pdf => Y
    7z
    rar
    cert
    zip => Y
    docx => Y
    xlsx => y
    pptx
    mp3
    ogg
    m4a
    3gpp
    3gp
    ts
    mp4
    mpeg
    mpg
    mov
    webm
    flv
    m4v
    wmv
    avi
    csv => Y
    xls => Y
    PPT => y
    PSD => Y
    TXT => Y
 */

internal enum MimeTypIcon {
    case html
}

internal let mimeTypeIcon = [
    "html": "chhtmlIcon",
    "htm": "chhtmlIcon",
    "shtml": "chhtmlIcon",
    "css": "chcssIcon",
    "xml": "chxmlIcon",
    "gif": "chgifIcon",
    "jpeg": "chjpegIcon",
    "jpg": "chjpgIcon",
    "js": "chjsIcon",
    "txt": "chtxtIcon",
    "png": "chpngIcon",
    "tif": "chtifIcon",
    "tiff": "chtifIcon",
    "doc": "chdocIcon",
    "docx": "chdocxIcon",
    "pdf": "chpdfIcon",
    "ppt": "chpptIcon",
    "pptx": "chpptxIcon",
    "mp4": "chmp4Icon",
    "avi": "chaviIcon",
    "mov": "chmovIcon",
    "mpeg": "chmpegIcon",
    "flv": "chflvIcon",
    "xlsx": "chxlsxIcon",
    "xls": "chxlsIcon",
    "zip": "chzipIcon"
    
]

internal let mimeTypes = [
    "md": "text/markdown",
    "html": "text/html",
    "htm": "text/html",
    "shtml": "text/html",
    "css": "text/css",
    "xml": "text/xml",
    "gif": "image/gif",
    "jpeg": "image/jpeg",
    "jpg": "image/jpeg",
    "js": "application/javascript",
    "atom": "application/atom+xml",
    "rss": "application/rss+xml",
    "mml": "text/mathml",
    "txt": "text/plain",
    "jad": "text/vnd.sun.j2me.app-descriptor",
    "wml": "text/vnd.wap.wml",
    "htc": "text/x-component",
    "png": "image/png",
    "tif": "image/tiff",
    "tiff": "image/tiff",
    "wbmp": "image/vnd.wap.wbmp",
    "ico": "image/x-icon",
    "jng": "image/x-jng",
    "bmp": "image/x-ms-bmp",
    "svg": "image/svg+xml",
    "svgz": "image/svg+xml",
    "webp": "image/webp",
    "woff": "application/font-woff",
    "jar": "application/java-archive",
    "war": "application/java-archive",
    "ear": "application/java-archive",
    "json": "application/json",
    "hqx": "application/mac-binhex40",
    "doc": "application/msword",
    "pdf": "application/pdf",
    "ps": "application/postscript",
    "eps": "application/postscript",
    "ai": "application/postscript",
    "rtf": "application/rtf",
    "m3u8": "application/vnd.apple.mpegurl",
    "xls": "application/vnd.ms-excel",
    "eot": "application/vnd.ms-fontobject",
    "ppt": "application/vnd.ms-powerpoint",
    "wmlc": "application/vnd.wap.wmlc",
    "kml": "application/vnd.google-earth.kml+xml",
    "kmz": "application/vnd.google-earth.kmz",
    "7z": "application/x-7z-compressed",
    "cco": "application/x-cocoa",
    "jardiff": "application/x-java-archive-diff",
    "jnlp": "application/x-java-jnlp-file",
    "run": "application/x-makeself",
    "pl": "application/x-perl",
    "pm": "application/x-perl",
    "prc": "application/x-pilot",
    "pdb": "application/x-pilot",
    "rar": "application/x-rar-compressed",
    "rpm": "application/x-redhat-package-manager",
    "sea": "application/x-sea",
    "swf": "application/x-shockwave-flash",
    "sit": "application/x-stuffit",
    "tcl": "application/x-tcl",
    "tk": "application/x-tcl",
    "der": "application/x-x509-ca-cert",
    "pem": "application/x-x509-ca-cert",
    "crt": "application/x-x509-ca-cert",
    "xpi": "application/x-xpinstall",
    "xhtml": "application/xhtml+xml",
    "xspf": "application/xspf+xml",
    "zip": "application/zip",
    "bin": "application/octet-stream",
    "exe": "application/octet-stream",
    "dll": "application/octet-stream",
    "deb": "application/octet-stream",
    "dmg": "application/octet-stream",
    "iso": "application/octet-stream",
    "img": "application/octet-stream",
    "msi": "application/octet-stream",
    "msp": "application/octet-stream",
    "msm": "application/octet-stream",
    "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "mid": "audio/midi",
    "midi": "audio/midi",
    "kar": "audio/midi",
    "mp3": "audio/mpeg",
    "ogg": "audio/ogg",
    "m4a": "audio/x-m4a",
    "ra": "audio/x-realaudio",
    "3gpp": "video/3gpp",
    "3gp": "video/3gpp",
    "ts": "video/mp2t",
    "mp4": "video/mp4",
    "mpeg": "video/mpeg",
    "mpg": "video/mpeg",
    "mov": "video/quicktime",
    "webm": "video/webm",
    "flv": "video/x-flv",
    "m4v": "video/x-m4v",
    "mng": "video/x-mng",
    "asx": "video/x-ms-asf",
    "asf": "video/x-ms-asf",
    "wmv": "video/x-ms-wmv",
    "avi": "video/x-msvideo"
]

internal func MimeType(ext: String?) -> String {
    let lowercase_ext: String = ext!.lowercased()
    if ext != nil && mimeTypes.contains(where: { $0.0 == lowercase_ext }) {
        return mimeTypes[lowercase_ext]!
    }
    return DEFAULT_MIME_TYPE
}

extension URL {
    public func mimeType() -> String {
        return MimeType(ext: self.pathExtension)
    }
}

extension NSURL {
    public func mimeType() -> String {
        return MimeType(ext: self.pathExtension)
    }
}

extension NSString {
    public func mimeType() -> String {
        return MimeType(ext: self.pathExtension)
    }
}

extension String {
    public func mimeType() -> String {
        return (self as NSString).mimeType()
    }
}

