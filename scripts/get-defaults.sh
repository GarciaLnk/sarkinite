#!/usr/bin/bash
#shellcheck disable=SC2154

# If image has -dx, assume they want the target to be dx and that version might be $2
if [[ ${image} =~ "-dx" ]]; then
	image=$(cut -d - -f 1 <<<"${image}")
	version=${target}
	target="dx"
fi

# if no image, kde
if [[ -z ${image} ]]; then
	image="kde"
fi

# if no target, base
if [[ -z ${target} ]]; then
	target="base"
# if $2 is version, assume that is version and target is base
elif [[ ${target} =~ beta ]]; then
	version=${target}
	target="base"
elif [[ ${target} =~ stable ]]; then
	version=${target}
	target="base"
elif [[ ${target} =~ latest ]]; then
	version=${target}
	target="base"
elif [[ ${target} =~ gts ]]; then
	version=${target}
	target="base"
fi

# if no version, set to stable
if [[ -z ${version} ]]; then
	version="stable"
fi
