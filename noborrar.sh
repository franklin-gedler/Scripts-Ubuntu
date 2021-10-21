#!/bin/bash

    # Variables que puedes tocar
    name="Dell-Command-Update-Application-for-Windows-10_GRVPK_WIN_4.3.0_A00_03.EXE"
    GITHUB_API_TOKEN="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"
    owner="franklin-gedler"
    repo="Scripts-Win10"
    tag="2"

    # Variables que no se tocan
    GH_API="https://api.github.com"
    GH_REPO="$GH_API/repos/$owner/$repo"
    GH_TAGS="$GH_REPO/releases/tags/$tag"
    AUTH="Authorization: token $GITHUB_API_TOKEN"
    CURL_ARGS="-LJO#"

    response=$(curl -sH "$AUTH" $GH_TAGS)
    eval $(echo "$response" | grep -C3 "name.:.\+$name" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
    #[ "$id" ] || { echo "Error: Failed to get asset id, response: $response" | awk 'length($0)<100' >&2; exit 1; }
    GH_ASSET="$GH_REPO/releases/assets/$id"
    echo "$GH_ASSET"

    # Download asset file.
    #echo "Downloading asset..." >&2
    #curl $CURL_ARGS -H 'Accept: application/octet-stream' "$GH_ASSET?access_token=$GITHUB_API_TOKEN"
	
    #curl $CURL_ARGS -H "Authorization: token $GITHUB_API_TOKEN" -H "Accept: application/octet-stream" "$GH_ASSET"
    
    #echo "$0 done." >&2

