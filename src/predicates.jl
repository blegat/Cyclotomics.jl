"""
    hash(α::Cyclotomic[, h::UInt])

A basic hashing function for cyclotomic elements; Note that unlike the `Base` types hashing of `Cyclotomic`s is expensive as it necessitates reducing to minimal embeding.
This is to keep `hash`ing consistent and reliable with respect to `==`, i.e. that the equality of elements implies the equality of `hash`es.
"""
function Base.hash(α::Cyclotomic, h::UInt)
    β = reduced_embedding(α)
    return hash(coeffs(β), hash(conductor(β), hash(Cyclotomic, h)))
end

function Base.:(==)(α::Cyclotomic, β::Cyclotomic)
    coeffs(α) == coeffs(β) && return true

    if conductor(α) == conductor(β)
        normalform!(α)
        normalform!(β)
        return coeffs(α) == coeffs(β)
    else
        l = lcm(conductor(α), conductor(β))
        return embed(α, l) == embed(β, l)
    end
end

Base.:(==)(α::Cyclotomic{T}, x::R) where {T,R<:Real} = α == Cyclotomic(1, [x])
Base.:(==)(x::Real, α::Cyclotomic) = α == x

function Base.isapprox(
    α::Cyclotomic{T},
    x::S;
    atol::Real = 0,
    rtol::Real = atol > 0 ? 0 : sqrt(max(eps(x), maximum(eps, coeffs(α)))),
) where {T<:AbstractFloat,S<:AbstractFloat}
    return isapprox(S(α), x; atol = atol, rtol = rtol)
end

function Base.isapprox(
    α::Cyclotomic{T},
    x::S;
    atol::Real = 0,
    rtol::Real = atol > 0 ? 0 : eps(x),
) where {T,S<:AbstractFloat}
    return isapprox(S(α), x; atol = atol, rtol = rtol)
end

Base.iszero(α::Cyclotomic) =
    all(iszero, values(α)) || (normalform!(α); all(iszero, values(α)))

Base.isreal(α::Cyclotomic) =
    α == conj(α) || conductor(reduced_embedding(α)) == 1

function Base.isone(α::Cyclotomic)
    β = reduced_embedding(α)
    conductor(β) == 1 || return false
    return isone(β[0])
end

"""
    isnormalized(α::Cyclotomic, basis)
Check if `α` is already in normal form with respect to the given basis.
"""
function isnormalized(α::Cyclotomic, basis = zumbroich_basis(conductor(α)))
    # return all(in(basis), exponents(α))
    for e in exponents(α)
        e in basis || return false
    end
    return true
end

function _all_equal(α::Cyclotomic, exps, value = α[first(exps)])
    # return all(e -> α[e] == val, exps)
    for e in exps
        α[e] == value || return false
    end
    return true
end
