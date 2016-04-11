set(_target_copy_dependencies_file "${CMAKE_CURRENT_LIST_FILE}")
set(_target_copy_dependencies_dir "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(_working_dir ${_target_copy_dependencies_dir} DIRECTORY)

function(target_copy_dependencies target)	
    if(MSVC)
		unset(_target_dirs)
		# get the output directory the libraries this target links to
		get_target_property(_link_libs ${target} LINK_LIBRARIES)
		foreach(_link_lib ${_link_libs})
			if(TARGET ${_link_lib})
				get_target_property(_type ${_link_lib} TYPE)
				if(_type STREQUAL "SHARED_LIBRARY")
					get_target_property(_output_dir ${_link_lib} RUNTIME_OUTPUT_DIRECTORY)
					if(_output_dir)
						list(APPEND _target_dirs ${_output_dir})
					endif()
				endif()
			endif()
		endforeach()
		# TODO add escaping for list
        add_custom_command( TARGET ${target} POST_BUILD
                            COMMAND ${CMAKE_COMMAND} -DTARGET_PATH=$<TARGET_FILE:${target}> -DTARGET_DIRS="${_target_dirs}" -DDEPENDENCIES_DIR=${DEPENDENCIES_DIR} -P ${_target_copy_dependencies_file}
                            )
    endif()
endfunction()

function(glob_dependencies_directories _root_dir out_var)
    file(GLOB_RECURSE _paths "${_root_dir}/*.dll")
	unset(_dirs)
    foreach(_path ${_paths})
		get_filename_component(_dir ${_path} DIRECTORY)		
		list(APPEND _dirs ${_dir})
	endforeach()	
	list(REMOVE_DUPLICATES _dirs)
    set(${out_var} ${_dirs} PARENT_SCOPE)
endfunction()

if(CMAKE_SCRIPT_MODE_FILE)   
	glob_dependencies_directories(${_working_dir} _dirs)
	list(APPEND _dirs ${TARGET_DIRS})
    include(BundleUtilities)
    include(GetPrerequisites)
    fixup_bundle("${TARGET_PATH}" "" "${_dirs}")   
endif()