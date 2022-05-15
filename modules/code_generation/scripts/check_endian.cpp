
static_assert (sizeof(int) != sizeof(char));

static constexpr const int LITTLE_ENDIAN = 0;
static constexpr const int BIG_ENDIAN = 1;

int main()
{
	int num = 1;

	if (*(char *)&num == 1)
		return LITTLE_ENDIAN;

	return BIG_ENDIAN;
}
