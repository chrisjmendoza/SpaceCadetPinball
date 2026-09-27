# Downloads SDL2 and SDL2_mixer Visual C++ development packages into /Libs
# when they are not already there, so that a fresh clone builds without manual setup.
# Archive extraction needs CMake 3.18+, older versions fall back to manual download.

set(SDL2_VC_VERSION 2.30.4)
set(SDL2_VC_SHA256 8dcb7fb74e7b228537e38faa8d1d16d767c08188a5e696d2cd2255775a0a9d8f)
set(SDL2_MIXER_VC_VERSION 2.8.0)
set(SDL2_MIXER_VC_SHA256 47a5713937f8d8b903a9c5555fef3ec73a793ef95abdd078773fc11fcb00ec8a)

function(download_sdl_package name url sha256 destination)
    if(EXISTS "${destination}/include")
        return()
    endif()

    if(CMAKE_VERSION VERSION_LESS 3.18)
        message(WARNING "${name} not found. Download ${url} and unpack it into ${destination}")
        return()
    endif()

    set(archive "${CMAKE_BINARY_DIR}/${name}.zip")
    set(extractDir "${CMAKE_BINARY_DIR}/${name}-extract")
    message(STATUS "Downloading ${url}")
    file(DOWNLOAD "${url}" "${archive}" EXPECTED_HASH SHA256=${sha256} STATUS status)
    list(GET status 0 statusCode)
    if(NOT statusCode EQUAL 0)
        list(GET status 1 statusText)
        message(FATAL_ERROR "Failed to download ${name}: ${statusText}")
    endif()

    # Packages contain a single versioned top level folder, e.g. SDL2-2.30.4
    file(REMOVE_RECURSE "${extractDir}")
    file(ARCHIVE_EXTRACT INPUT "${archive}" DESTINATION "${extractDir}")
    file(GLOB extractedRoot LIST_DIRECTORIES true "${extractDir}/*")
    file(REMOVE_RECURSE "${destination}")
    get_filename_component(destinationParent "${destination}" DIRECTORY)
    file(MAKE_DIRECTORY "${destinationParent}")
    file(RENAME "${extractedRoot}" "${destination}")
    file(REMOVE_RECURSE "${extractDir}")
    file(REMOVE "${archive}")
endfunction()

download_sdl_package(SDL2
    "https://github.com/libsdl-org/SDL/releases/download/release-${SDL2_VC_VERSION}/SDL2-devel-${SDL2_VC_VERSION}-VC.zip"
    ${SDL2_VC_SHA256}
    "${CMAKE_SOURCE_DIR}/Libs/SDL2")
download_sdl_package(SDL2_mixer
    "https://github.com/libsdl-org/SDL_mixer/releases/download/release-${SDL2_MIXER_VC_VERSION}/SDL2_mixer-devel-${SDL2_MIXER_VC_VERSION}-VC.zip"
    ${SDL2_MIXER_VC_SHA256}
    "${CMAKE_SOURCE_DIR}/Libs/SDL2_mixer")
