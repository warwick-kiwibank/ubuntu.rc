with_entries(
    .key as $file
    | .value |= walk(
        if type == "object" then
            .file = $file
        else
            .
        end
    )
)
| (
    [
        (
            paths
            | select(.[1] == "locals" and (.[3] | match("cidrs")?))
            | .[0:3]
        ) as $path
        |  getpath($path)
    ]
    | map(with_entries(select(.key | test("cidr"))))[]
) as $cidrs
| with_entries(
    .key as $file
    | .value = (
        .value
        | with_entries(
            if (.value | type == "object") then
                .value.file = $file
            else
                .
            end
        )
    )
)
| [
    (
        paths
        | select(.[2] | match("security_group$")?)
    ) as $paths
    | getpath($paths)[]?
    | add
    | "\\$\\{local\\.(?<ref>[a-zA-Z0-9_]+)\\}" as $regex
    | with_entries(
        if .key == "ingress" then
            .value |= map(
                .cidr_blocks |= (
                    if type == "array" then
                        map(
                            if test($regex) then
                                {
                                    "reference": .,
                                    "values": (
                                        capture($regex).ref as $ref
                                        | ($cidrs[$ref] // .)
                                    )
                                }
                            else
                                .
                            end
                        )
                    elif type == "string" then
                        if test($regex) then
                            {
                                "reference": .,
                                "values": (
                                    capture($regex).ref as $ref
                                    | ($cidrs[$ref] // .)
                                )
                            }
                        else
                            .
                        end
                    else
                        .
                    end
                )
            )
        else
            .
        end
    )
]