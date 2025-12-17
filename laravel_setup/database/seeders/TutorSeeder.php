<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\Tutor;
class TutorSeeder extends Seeder
{
    public function run()
    {
        Tutor::create(['name' => 'Nguyễn Văn Hùng', 'avatar_url' => 'https://i.pravatar.cc/150?u=1', 'bio' => 'GV Toán', 'hourly_rate' => 200000, 'rating' => 4.8, 'review_count' => 120, 'location' => 'Hà Nội', 'address' => 'Cầu Giấy', 'is_verified' => true, 'subjects' => ['Toán', 'Lý'], 'teaching_mode' => ['Online', 'Offline'], 'weekly_schedule' => ['2' => ['08:00 - 10:00']]]);
        Tutor::create(['name' => 'Trần Thị Mai', 'avatar_url' => 'https://i.pravatar.cc/150?u=2', 'bio' => 'SV Ngoại Ngữ', 'hourly_rate' => 150000, 'rating' => 4.5, 'review_count' => 45, 'location' => 'Hồ Chí Minh', 'subjects' => ['Anh', 'Văn'], 'teaching_mode' => ['Online'], 'weekly_schedule' => ['3' => ['18:00 - 20:00']]]);
        for ($i = 3; $i <= 10; $i++)
            Tutor::create(['name' => "Gia sư $i", 'avatar_url' => "https://i.pravatar.cc/150?u=$i", 'bio' => 'Gia sư $i', 'hourly_rate' => 100000, 'rating' => 4.0, 'location' => 'Online', 'subjects' => ['Toán'], 'teaching_mode' => ['Online']]);
    }
}
